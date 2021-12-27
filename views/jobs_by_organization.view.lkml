view: jobs_by_organization {
    derived_table: {
      sql: SELECT job_id,
                  reservation_id,
                  creation_time,
                  start_time,
                  end_time,
                  error_result,
                  total_bytes_processed,
                  total_slot_ms,
                  job_stages.shuffle_output_bytes as shuffle_output_bytes,
                  job_stages.shuffle_output_bytes_spilled as shuffle_output_bytes_spilled
              FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo, UNNEST(job_stages) as job_stages
            WHERE
          -- Includes jobs created 8 days ago but completed 7 days ago
          jbo.creation_time
            BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY)
            AND CURRENT_TIMESTAMP()
          AND jbo.end_time
            BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
            AND CURRENT_TIMESTAMP()
         ;;
  }

  dimension: job_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.job_id ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension_group: creation {
    type: time
    timeframes: [
      raw,
      time,
      second,
      minute,
      minute5,
      minute15,
      minute30,
      hour,
      date,
      week,
      month,
      time_of_day,
      day_of_week,
      hour_of_day
    ]
    sql: ${TABLE}.creation_time ;;
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

  #dimension: job_duration_milliseconds {
  #  type: number
  #  sql: TIMESTAMP_DIFF(${end_time}, ${start_time}, MILLISECOND) ;;
  #}

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
    description: "Total slots used multiplied by total ms the job ran for"
    sql: ${TABLE}.total_slot_ms ;;
  }

 #dimension: query_total_slot {
 #  label: "Total slots used for a query"
 #  type: number
 #  sql: ${total_slot_ms}/NULLIF(${job_duration_milliseconds},0) ;;
 #}

  measure: total_shuffle_output_terabytes {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}.shuffle_output_bytes/(1000*1000*1000*1000) ;;
  }

  measure: total_shuffle_output_terabytes_spilled {
    type: sum
    value_format_name: decimal_2
    sql: ${TABLE}.shuffle_output_bytes_spilled/(1000*1000*1000*1000) ;;
  }

  measure: average_weekly_slot_usage   {
    type: sum_distinct
    sql_distinct_key: ${job_id} ;;
    value_format_name: decimal_2
    sql: SAFE_DIVIDE(${total_slot_ms}, (1000 * 60 * 60 * 24 * 7)) ;;
  }

  measure: weekly_reservation_utilization_based_on_latest_capacity {
    type: number
    value_format_name: percent_2
    sql: SAFE_DIVIDE(${average_weekly_slot_usage}, ${reservation_capacity.latest_capacity}) ;;
  }

  measure: avg_job_duration_seconds {
    type: average_distinct
    sql_distinct_key: ${job_id} ;;
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: median_job_duration_seconds {
    type: median_distinct
    sql_distinct_key: ${job_id} ;;
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: count_errors {
    type: sum_distinct
    sql_distinct_key: ${job_id} ;;
    sql: CASE WHEN ${error_result_reason} IS NOT NULL THEN 1 ELSE 0 END ;;
  }

}

view: reservation_capacity {
  derived_table: {
    sql:
      SELECT
      CONCAT("bq-admin-spotify:EU.", rcp.reservation_name) AS reservation_id,
      rcp.slot_capacity as latest_capacity
      FROM
      `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT` AS rcp
      WHERE
      -- This subquery returns the latest slot capacity for each reservation
      -- by extracting the reservation with the maximum timestamp
      (rcp.reservation_name, rcp.change_timestamp) IN (
      SELECT AS STRUCT reservation_name, MAX(change_timestamp)
      FROM
      `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.RESERVATION_CHANGES_BY_PROJECT`
      GROUP BY reservation_name)
    ;;
  }

  dimension: reservation_id   {
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  dimension: latest_capacity   {
    type: number
    sql: ${TABLE}.latest_capacity ;;
  }
}
