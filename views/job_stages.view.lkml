view: job_stages {

  dimension: shuffle_output_bytes {
    type: number
  }

  dimension: shuffle_output_bytes_spilled {
    type: number
  }

  measure: total_shuffle_output_terabytes {
    type: sum
    value_format_name: decimal_2
    sql: ${shuffle_output_bytes}/(1000*1000*1000*1000) ;;
  }

  measure: total_shuffle_output_terabytes_spilled {
    type: sum
    value_format_name: decimal_2
    sql: ${shuffle_output_bytes_spilled}/(1000*1000*1000*1000) ;;
  }
}
