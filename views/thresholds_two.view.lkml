view: thresholds_two {
  derived_table: {
    interval_trigger: "24 hours"
    sql: SELECT reservation_id, creation_date, sum_errors
        FROM (SELECT reservation_id,
                     EXTRACT(DATE from jbo.creation_time) AS creation_date,
                     SUM(CASE WHEN error_result IS NOT NULL THEN 1 ELSE 0 END) OVER (PARTITION BY reservation_id, EXTRACT(DATE from jbo.creation_time)) AS sum_errors
                     FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
                     WHERE
                     jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY) AND CURRENT_TIMESTAMP())
                     -- AND jbo.end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY) AND CURRENT_TIMESTAMP())
        GROUP BY reservation_id, creation_date, sum_errors
        ;;
  }

  dimension: reservation_id   {
    primary_key: yes
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: sum_errors   {
    type: number
    sql: ${TABLE}.sum_errors ;;
  }

  measure: sum_errors_90th_percentile {
    type: percentile
    percentile: 90
    sql: ${TABLE}.sum_errors ;;
  }
}
