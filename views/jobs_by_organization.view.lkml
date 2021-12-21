view: jobs_by_organization {
    derived_table: {
      sql: SELECT *
              from `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION`
         ;;
  }

  dimension: job_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.job_id ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: creation_time   {
    type: string
    sql: ${TABLE}.creation_time ;;
  }

  dimension: creation_date   {
    type: date
    datatype: date
    sql: EXTRACT(DATE FROM ${creation_time}) ;;
  }

  dimension: start_time   {
    type: string
    sql: ${TABLE}.start_time ;;
  }

  dimension: end_time   {
    type: string
    sql: ${TABLE}.end_time ;;
  }

  dimension: job_duration_seconds {
    type: number
    sql: TIMESTAMP_DIFF(${end_time}, ${start_time}, SECOND) ;;
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

  dimension: error_result_reason {
    type: string
    sql: ${TABLE}.error_result.reason ;;
  }

  dimension: total_bytes_processed {
    type: number
    sql: ${TABLE}.total_bytes_processed ;;
  }

  dimension: total_slot_ms {
    type: number
    sql: ${TABLE}.total_slot_ms ;;
  }

  dimension: avg_slots {
    type: number
    sql: SAFE_DIVIDE(${total_slot_ms}, (TIMESTAMP_DIFF(${end_time}, ${start_time}, MILLISECOND))) ;;
  }

  dimension: statement_type {
    type: string
    sql: (CASE WHEN ${TABLE}.statement_type IS NULL THEN 'N/A' ELSE ${TABLE}.statement_type END) ;;
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

  measure: count_errors {
    type: sum
    sql: (CASE WHEN ${error_result_reason} IS NOT NULL THEN 1 ELSE 0 END) ;;
  }
}

view: jobs_by_organization_job_stages {

    dimension: shuffle_output_terabytes {
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.shuffle_output_bytes/(1000*1000*1000*1000) ;;
    }

    measure: total_shuffle_output_terabytes {
      type: sum
      value_format_name: decimal_2
      sql: ${shuffle_output_terabytes} ;;
    }

    dimension: shuffle_output_terabytes_spilled {
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.shuffle_output_bytes_spilled/(1000*1000*1000*1000) ;;
    }

    measure: total_shuffle_output_terabytes_spilled {
      type: sum
      value_format_name: decimal_2
      sql: ${shuffle_output_terabytes_spilled} ;;
    }
}

  #dimension: sum_shuffle_output_megabytes_spilled {
  #  type: number
  #  sql: (SELECT SUM(shuffle_output_bytes_spilled)/1000000 FROM UNNEST(${job_stages}));;
  #  value_format_name: decimal_2
  #  label: "Megabytes Spilled"
  #}

  #measure: total_shuffle_output_gibibytes_spilled {
  #  type: sum
  #  label: "Shuffle GB Spilled"
  #  sql: ${shuffle_output_bytes_spilled} / (1024*1024*1024) ;;
  #  value_format_name: decimal_2
  #}
