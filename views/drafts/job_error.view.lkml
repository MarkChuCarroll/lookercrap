view: job_error {
  derived_table: {
    sql: SELECT
        job_id,
        project_id,
        reservation_id,
        user_email,
        EXTRACT(DATE FROM creation_time) AS creation_date,
        job_type,
        CASE WHEN statement_type IS NULL THEN 'N/A' ELSE statement_type END AS statement_type,
        error_result.reason AS error_result_reason
      FROM
        `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION`
      WHERE
        -- Jobs that resulted in an error will have the error_result.reason
        -- field populated
        error_result.reason IS NOT NULL
    ;;
  }

  dimension: job_id   {
    type: string
    sql: ${TABLE}.job_id ;;
  }

  dimension: project_id   {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}.user_email ;;
  }

  dimension: creation_date   {
    type: date
    datatype: date
    sql: ${TABLE}.creation_date ;;
  }

  dimension: job_type {
    type: string
    sql: ${TABLE}.job_type ;;
  }

  dimension: statement_type {
    type: string
    sql: ${TABLE}.statement_type ;;
  }

  dimension: error_result_reason {
    type: string
    sql: ${TABLE}.error_result_reason ;;
  }

  measure: count_errors {
    type: number
    sql: COUNT(${job_id}) ;;
  }

}
