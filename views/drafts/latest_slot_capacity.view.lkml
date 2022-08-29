view: latest_slot_capacity {
   derived_table: {
     sql: SELECT
      rcp.reservation_name, rcp.slot_capacity
    FROM
      `bq-admin-spotify.region-{% parameter region %}.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT` AS rcp
    WHERE
      -- This subquery returns the latest slot capacity for each reservation
      -- by extracting the reservation with the maximum timestamp
      (rcp.reservation_name, rcp.change_timestamp) IN (
        SELECT AS STRUCT reservation_name, MAX(change_timestamp)
        FROM
          `bq-admin-spotify.region-{% parameter region %}.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT`
        GROUP BY reservation_name)
       ;;
   }

  parameter: region {
    type: unquoted
    allowed_value: { value: "eu" }
    allowed_value: { value: "us" }
  }

  dimension: reservation_name   {
    type: string
    sql: ${TABLE}.reservation_name ;;
  }

  dimension: slot_capacity {
    type: number
    sql: ${TABLE}.slot_capacity ;;
  }
}
