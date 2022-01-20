view: thresholds {
  derived_table: {
    interval_trigger: "24 hours"
    sql: SELECT reservation_id,
                running_avg_job_duration_seconds
                FROM (SELECT reservation_id,
                      ROUND(AVG(TIMESTAMP_DIFF(end_time, start_time, SECOND)) OVER (PARTITION BY reservation_id), 2) AS running_avg_job_duration_seconds
                      FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
                      WHERE
                      jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY) AND CURRENT_TIMESTAMP())
                      -- AND jbo.end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 60 DAY) AND CURRENT_TIMESTAMP())
                GROUP BY reservation_id, running_avg_job_duration_seconds
         ;;
  }

  dimension: reservation_id   {
    primary_key: yes
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  measure: running_avg_job_duration_seconds {
    type: average
    sql: ${TABLE}.running_avg_job_duration_seconds ;;
  }

}
