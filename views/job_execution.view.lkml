view: job_execution {
   derived_table: {
     sql: SELECT
          project_id,
          job_id,
          reservation_id,
          EXTRACT(DATE FROM creation_time) AS creation_date,
          creation_time,
          end_time,
          TIMESTAMP_DIFF(end_time, start_time, SECOND) AS job_duration_seconds,
          job_type,
          user_email,
          state,
          error_result,
          total_bytes_processed,
          -- Average slot utilization per job is calculated by dividing
          -- total_slot_ms by the millisecond duration of the job
          SAFE_DIVIDE(total_slot_ms, (TIMESTAMP_DIFF(end_time, start_time, MILLISECOND))) AS avg_slots
        FROM
          `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION`
        ORDER BY
          creation_time DESC
       ;;
 }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: job_id {
    type: string
    sql: ${TABLE}.job_id ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: creation_date   {
    type: date
    datatype: date
    sql: ${TABLE}.creation_date ;;
  }

  dimension: creation_time   {
    type: string
    sql: ${TABLE}.creation_time ;;
  }

  dimension: end_time   {
    type: string
    sql: ${TABLE}.end_time ;;
  }

  dimension: job_duration_seconds {
    type: number
    sql: ${TABLE}.job_duration_seconds ;;
  }

  dimension: job_type {
    type: string
    sql: ${TABLE}.job_type ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}.user_email ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: error_result {
    type: string
    sql: ${TABLE}.error_result ;;
  }

  dimension: total_bytes_processed {
    type: number
    sql: ${TABLE}.total_bytes_processed ;;
  }

  dimension: avg_slots {
    type: number
    sql: ${TABLE}.avg_slots ;;
  }

  measure: avg_job_duration_seconds {
    type: average
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: median_job_duration_seconds {
    type: median
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }


}
