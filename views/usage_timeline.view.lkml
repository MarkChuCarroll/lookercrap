view: usage_timeline {
  derived_table: {
    sql: SELECT
         res.period_start,
         res.reservation_id,
         SUM(jobs.period_slot_ms) / 1000 / 60 / 60 AS period_slot_hours,
         ANY_VALUE(res.slots_assigned) AS slots_assigned,
         ANY_VALUE(res.slots_max_assigned) AS slots_max_assigned,
         FROM
         `region-eu.INFORMATION_SCHEMA.JOBS_TIMELINE_BY_ORGANIZATION` jobs
         JOIN
         `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATIONS_TIMELINE_BY_PROJECT` res
         ON
         TIMESTAMP_TRUNC(jobs.period_start, HOUR) = res.period_start
         AND jobs.reservation_id = res.reservation_id
         WHERE
         jobs.job_creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
         AND CURRENT_TIMESTAMP()
         GROUP BY
         period_start,
         reservation_id
         ORDER BY
         period_start DESC, reservation_id
        -- see https://cloud.google.com/bigquery/docs/information-schema-jobs-timeline#examples_2
  ;;
  }

  dimension: period_start   {
    type: date_hour
    sql: ${TABLE}.period_start ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  measure: period_slot_hours {
    type: sum
    sql: ${TABLE}.period_slot_hours ;;
  }

  measure: slots_assigned {
    type: sum
    sql: ${TABLE}.slots_assigned ;;
  }

  measure: slots_max_assigned {
    type: sum
    sql: ${TABLE}.slots_max_assigned ;;
  }


}
