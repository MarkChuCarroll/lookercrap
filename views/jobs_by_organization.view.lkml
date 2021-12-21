view: jobs_by_organization {
    derived_table: {
      sql: SELECT *
              from `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION`
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
    sql: EXTRACT(DATE FROM ${TABLE}.creation_time) ;;
  }

  #dimension: job_stages {
  #  hidden: yes
  #  type: string
  #  sql: ${TABLE}.job_stages ;;
  #}
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
