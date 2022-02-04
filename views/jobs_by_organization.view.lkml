view: jobs_by_organization {
    derived_table: {
      sql: SELECT job_id,
                  reservation_id,
                  project_id,
                  creation_time,
                  start_time,
                  end_time,
                  error_result,
                  total_bytes_processed,
                  total_slot_ms,
                  job_stages
              FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
            -- filter by the partition column first to limit the amount of data scanned
            -- allows for jobs created yesterday
            -- WHERE
            -- jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 DAY) AND CURRENT_TIMESTAMP()
            -- AND jbo.end_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) AND CURRENT_TIMESTAMP()
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

  dimension: project_id   {
    type: string
    sql: ${TABLE}.project_id ;;
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

  dimension: error_result {
    type: string
    sql: ${TABLE}.error_result ;;
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

  measure: average_slot_usage_last_24h   {
    #type: sum_distinct
    #sql_distinct_key: ${job_id} ;;
    type: sum
    value_format_name: decimal_2
    sql: SAFE_DIVIDE(${total_slot_ms}, (1000 * 60 * 60 * 24)) ;;
    link: {
      label: "Show 24h time series"
      url: "/looks/5?&f[usage_timeline.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
  }

  measure: reservation_utilization {
    type: number
    #value_format_name: percent_2
    required_fields: [reservation_capacity.latest_capacity]
    sql: ROUND(SAFE_DIVIDE(${average_slot_usage_last_24h}, ${reservation_capacity.latest_capacity}) * 100, 2) ;;
    html:
    {% if value > 100 %}
    <p style="color: black; background-color: lightcoral">{{ rendered_value }} %</p>
    {% elsif value > 95 %}
    <p style="color: black; background-color: orange">{{ rendered_value }} %</p>
    {% elsif value > 80 %}
    <p style="color: black; background-color: gold">{{ rendered_value }} %</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ rendered_value }} %</p>
    {% endif %} ;;
  }

  measure: avg_job_duration_seconds {
    #type: average_distinct
    #sql_distinct_key: ${job_id} ;;
    type: average
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: avg_job_duration_seconds_vs_threshold {
    type: number
    sql: ROUND(SAFE_DIVIDE(${avg_job_duration_seconds}, ${thresholds.p90_avg_job_duration}) *100, 2) ;;
    #required_fields: [avg_job_duration_seconds, thresholds.p90_avg_job_duration]
    link: {
      label: "Show slowest jobs"
      url: "/looks/2?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    link: {
      label: "Show 7d time series"
      url: "/looks/4?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    link: {
      label: "6 months P90 of {{ thresholds.p90_avg_job_duration._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value > 100 %}
    <p style="color: black; background-color: lightcoral">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% elsif value > 95 %}
    <p style="color: black; background-color: orange">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% elsif value > 80 %}
    <p style="color: black; background-color: gold">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: median_job_duration_seconds {
    #type: median_distinct
    #sql_distinct_key: ${job_id} ;;
    type: median
    value_format_name: decimal_2
    sql: ${job_duration_seconds} ;;
  }

  measure: sum_errors {
    #type: sum_distinct
    #sql_distinct_key: ${job_id} ;;
    type: sum
    sql: CASE WHEN ${error_result} IS NOT NULL THEN 1 ELSE 0 END ;;
  }

  measure: sum_errors_vs_threshold {
    #type: sum_distinct
    #sql_distinct_key: ${job_id} ;;
    type: number
    sql: ROUND(SAFE_DIVIDE(${sum_errors}, ${thresholds.p90_sum_errors}) *100, 2) ;;
    link: {
      label: "Show 30d time series"
      url: "/looks/7?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    link: {
      label: "6 months P90 of {{ thresholds.p90_sum_errors._rendered_value }}"
      url: "/looks/6?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value > 100 %}
    <p style="color: black; background-color: lightcoral">{{ sum_errors._rendered_value }}</p>
    {% elsif value > 95 %}
    <p style="color: black; background-color: orange">{{ sum_errors._rendered_value }}</p>
    {% elsif value > 80 %}
    <p style="color: black; background-color: gold">{{ sum_errors._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_errors._rendered_value }}</p>
    {% endif %} ;;
  }

}
