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
            -- filter by the partition column first to limit the amount of data scanned
            -- allows for jobs created before the 7 day end_time filter
            jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 DAY) AND CURRENT_TIMESTAMP()
            AND jbo.end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) AND CURRENT_TIMESTAMP()
            -- AND job_type = "QUERY"
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

  measure: average_slot_usage_last_24h   {
    type: sum_distinct
    sql_distinct_key: ${job_id} ;;
    value_format_name: decimal_2
    sql: SAFE_DIVIDE(${total_slot_ms}, (1000 * 60 * 60 * 24)) ;;
  }

  measure: reservation_utilization {
    type: number
    #value_format_name: percent_2
    sql: ROUND(SAFE_DIVIDE(${average_slot_usage_last_24h}, ${reservation_capacity.latest_capacity}) * 100, 2) ;;
    html:
    {% if value > 100 %}
    <font color="red">{{ rendered_value }} %</font>
    {% elsif value > 95 %}
    <font color="orange">{{ rendered_value }} %</font>
    {% elsif value > 80 %}
    <font color="yellow">{{ rendered_value }} %</font>
    {% else %}
    <font color="green">{{ rendered_value }} %</font>
    {% endif %} ;;
  }

  measure: avg_job_duration_seconds {
    type: average_distinct
    sql_distinct_key: ${job_id} ;;
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: avg_job_duration_seconds_vs_threshold {
    type: number
    sql: ROUND(SAFE_DIVIDE(${avg_job_duration_seconds}, ${thresholds.running_avg_job_duration_seconds}) *100, 2) ;;
    html:
    {% if value > 100 %}
    <p style="color: black; background-color: lightcoral">{{ avg_job_duration_seconds._rendered_value }} - above 60d running avg of {{ thresholds.running_avg_job_duration_seconds._rendered_value }}</p>
    {% elsif value > 95 %}
    <p style="color: black; background-color: orange">{{ avg_job_duration_seconds._rendered_value }} - 5% below 60d running avg of {{ thresholds.running_avg_job_duration_seconds._rendered_value }}</p>
    {% elsif value > 80 %}
    <p style="color: black; background-color: gold">{{ avg_job_duration_seconds._rendered_value }} - 20% below 60d running avg of {{ thresholds.running_avg_job_duration_seconds._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ avg_job_duration_seconds._rendered_value }} - way below 60d running avg of {{ thresholds.running_avg_job_duration_seconds._rendered_value }}</p>
    {% endif %} ;;
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
