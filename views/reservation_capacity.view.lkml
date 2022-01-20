view: reservation_capacity {
  derived_table: {
    sql:
      SELECT
      CONCAT("bq-admin-spotify:EU.", rcp.reservation_name) AS reservation_id,
      rcp.slot_capacity as latest_capacity
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
    ;;
  }

  dimension: reservation_id   {
    primary_key: yes
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: latest_capacity   {
    type: number
    sql: ${TABLE}.latest_capacity ;;
  }
}
