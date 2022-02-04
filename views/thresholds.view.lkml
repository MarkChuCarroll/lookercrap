view: thresholds {
  derived_table: {
    interval_trigger: "24 hours"
    sql: SELECT reservation_id, creation_date, daily_sum_errors, daily_avg_job_duration
        FROM (SELECT reservation_id,
                     EXTRACT(DATE from jbo.creation_time) AS creation_date,
                     SUM(CASE WHEN error_result IS NOT NULL THEN 1 ELSE 0 END) OVER (PARTITION BY reservation_id, EXTRACT(DATE from jbo.creation_time)) AS daily_sum_errors,
                     ROUND(AVG(TIMESTAMP_DIFF(end_time, start_time, SECOND)) OVER (PARTITION BY reservation_id, EXTRACT(DATE from jbo.creation_time)), 2) AS daily_avg_job_duration
                     FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
                     WHERE
                     jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY) AND CURRENT_TIMESTAMP())
                     -- AND jbo.end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY) AND CURRENT_TIMESTAMP())
        GROUP BY reservation_id, creation_date, daily_sum_errors, daily_avg_job_duration
         ;;
  }

  dimension: reservation_id   {
    primary_key: yes
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: daily_sum_errors   {
    type: number
    sql: ${TABLE}.daily_sum_errors ;;
  }

  dimension: daily_avg_job_duration   {
    type: number
    sql: ${TABLE}.daily_avg_job_duration ;;
  }

  measure: p90_sum_errors {
    type: percentile
    percentile: 90
    sql: ${TABLE}.daily_sum_errors ;;
  }

  measure: p90_avg_job_duration {
    type: percentile
    percentile: 90
    sql: ${TABLE}.daily_avg_job_duration ;;
  }

}
