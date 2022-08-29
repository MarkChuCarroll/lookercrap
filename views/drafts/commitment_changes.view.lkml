view: commitment_changes {
  derived_table: {
    sql:
          SELECT
            change_timestamp,
            commitment_plan,
            action,
            EXTRACT(DATE FROM change_timestamp) AS start_date,
            -- Compute the stop date of a commitment by looking at the following
            -- change_timestamp and subtracting one day. This works because monthly
            -- and yearly commitments cannot be deleted on the same day
            -- they were created.
            IFNULL(
              LEAD(DATE_SUB(EXTRACT(DATE FROM change_timestamp), INTERVAL 1 DAY))
                OVER (PARTITION BY state ORDER BY change_timestamp),
              CURRENT_DATE()) AS stop_date,
            -- In order to calculate the cumulative slots up to this point, add
            -- the slot count of new commitments (indicated by an UPDATE action)
            -- and subtract the slot count of deleted commitments
            SUM(CASE WHEN cccp.action = 'UPDATE' THEN cccp.slot_count ELSE cccp.slot_count * -1 END)
              -- Cumulative slots are tracked by their state and carried over from
              -- previous rows
              OVER (
                PARTITION BY state
                ORDER BY change_timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
              ) AS slot_cummulative,
              slot_count,
            -- In the event that multiple changes occurred in one day, we keep track
            -- of the most recent cumulative value by using row numbers
            ROW_NUMBER()
              OVER (
                PARTITION BY EXTRACT(DATE FROM change_timestamp)
                ORDER BY change_timestamp DESC
              ) AS rn
          FROM
            `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.CAPACITY_COMMITMENT_CHANGES_BY_PROJECT` AS cccp
          -- In this case, we only want to look at active commitments that are
          -- monthly or annual, not flex
          WHERE
            state = 'ACTIVE'
            --AND commitment_plan != 'FLEX'
          ORDER BY change_timestamp
       ;;
  }

  dimension: change_timestamp   {
    type: string
    sql: ${TABLE}.change_timestamp ;;
  }

  dimension: commitment_plan   {
    type: string
    sql: ${TABLE}.commitment_plan ;;
  }

  dimension: action   {
    type: string
    sql: ${TABLE}.action ;;
  }

  dimension: start_date   {
    type: date
    sql: ${TABLE}.start_date ;;
  }

  dimension: stop_date   {
    type: date
    sql: ${TABLE}.stop_date ;;
  }

  dimension: slot_cummulative   {
    type: number
    sql: ${TABLE}.slot_cummulative ;;
  }

  dimension: slot_count   {
    type: number
    sql: ${TABLE}.slot_count ;;
  }

  dimension: rn   {
    type: number
    sql: ${TABLE}.rn ;;
  }
}
