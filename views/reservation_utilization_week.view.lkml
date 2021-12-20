view: reservation_utilization_week {
  derived_table: {
    sql: WITH
        reservation_slot_capacity AS (
          SELECT
            -- Concatenation is needed as RESERVATION_CHANGES_BY_PROJECT only
            -- includes reservation name but in order to join with
            -- JOBS_BY_ORGANIZATION, reservation id is required
            CONCAT("bq-admin-spotify:EU.", reservation_name) AS reservation_id,
            change_timestamp AS start_time,
            IFNULL(
              LEAD(change_timestamp)
                OVER (
                  PARTITION BY reservation_name
                  ORDER BY change_timestamp ASC),
              CURRENT_TIMESTAMP()) AS end_time,
            action,
            slot_capacity
          FROM
            `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT`
        ),
        -- This table retrieves only the current slot capacity of a reservation
        latest_slot_capacity AS (
          SELECT
            rcp.reservation_name,
            rcp.slot_capacity,
            CONCAT("bq-admin-spotify:EU.", rcp.reservation_name) AS reservation_id,
          FROM
            `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT` AS rcp
          WHERE
            -- This subquery returns the latest slot capacity for each reservation
            -- by extracting the reservation with the maximum timestamp
            (rcp.reservation_name, rcp.change_timestamp) IN (
              SELECT AS STRUCT reservation_name, MAX(change_timestamp)
              FROM
                `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT`
              GROUP BY reservation_name)
        )
      -- Compute the average slot utilization and average reservation utilization
      SELECT
        jbo.reservation_id,
        -- Slot usage is calculated by aggregating total_slot_ms for all jobs
        -- in the last week and dividing by the number of milliseconds in a week
        SAFE_DIVIDE(SUM(jbo.total_slot_ms), (1000 * 60 * 60 * 24 * 7)) AS average_weekly_slot_usage,
        AVG(rsc.slot_capacity) AS average_reservation_capacity,
        SAFE_DIVIDE(
            SAFE_DIVIDE(
                SUM(jbo.total_slot_ms),
                1000 * 60 * 60 * 24 * 7
            ),
            AVG(rsc.slot_capacity)
        ) AS reservation_utilization,

        lsc.slot_capacity AS latest_capacity
      FROM
        `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
      -- Join the slot capacity history
      LEFT JOIN reservation_slot_capacity rsc
        ON
          jbo.reservation_id = rsc.reservation_id
          AND jbo.creation_time >= rsc.start_time
          AND jbo.creation_time < rsc.end_time
      -- Join the latest slot capacity
      LEFT JOIN latest_slot_capacity lsc
        ON
          jbo.reservation_id = lsc.reservation_id
      WHERE
        -- Includes jobs created 8 days ago but completed 7 days ago
        jbo.creation_time
          BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY)
          AND CURRENT_TIMESTAMP()
        AND jbo.end_time
          BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
          AND CURRENT_TIMESTAMP()
      GROUP BY
        reservation_id,
        lsc.slot_capacity
      ORDER BY
        reservation_id DESC
       ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: average_weekly_slot_usage   {
    type: number
    sql: ${TABLE}.average_weekly_slot_usage ;;
  }

  dimension: average_reservation_capacity   {
    type: number
    sql: ${TABLE}.average_reservation_capacity ;;
  }

  dimension: reservation_utilization   {
    type: number
    sql: ${TABLE}.reservation_utilization ;;
  }

  dimension: latest_capacity   {
    type: number
    sql: ${TABLE}.latest_capacity ;;
  }
}
