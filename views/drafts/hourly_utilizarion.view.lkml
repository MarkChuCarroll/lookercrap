view: hourly_utilization {
  derived_table: {
    sql: SELECT
        TIMESTAMP_TRUNC(jbo.creation_time, HOUR) as usage_time,
        EXTRACT(DATE from jbo.creation_time) as usage_date,
        jbo.reservation_id,
        jbo.project_id,
        jbo.job_type,
        jbo.user_email,
        SUM(jbo.total_slot_ms) / (1000 * 60 * 60) as average_hourly_slot_usage,
      FROM
        `region-{% parameter region %}.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
      GROUP BY
        usage_time,
        usage_date,
        jbo.project_id,
        jbo.reservation_id,
        jbo.job_type,
        jbo.user_email
      ORDER BY
        usage_time ASC
       ;;
  }

  parameter: region {
    type: unquoted
    allowed_value: { value: "eu" }
    allowed_value: { value: "us" }
  }

  dimension: usage_time {
    type: date_time
    sql: ${TABLE}.usage_time ;;
  }

  dimension: usage_date {
    type: date
    sql: ${TABLE}.usage_date ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: job_type {
    type: string
    sql: ${TABLE}.job_type ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}.user_email ;;
  }

  measure: sum_average_hourly_slot_usage {
    type: sum
    sql: ${TABLE}.average_hourly_slot_usage ;;
  }
}
