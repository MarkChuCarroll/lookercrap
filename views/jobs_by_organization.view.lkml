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

  dimension: job_stages {
    hidden: yes
    type: string
    sql: ${TABLE}.job_stages ;;
  }

  dimension: shuffle_terabytes_spilled {
    type: number
    sql: (SELECT SUM(shuffle_output_bytes_spilled)/(1000*1000*1000*1000) FROM UNNEST(${job_stages})) ;;
    value_format_name: decimal_2
  }

  measure: count_jobs {
    type:  count
  }

  measure: sum_stopped {
    type: sum
    sql: CASE WHEN ${error_result_reason} = 'stopped' THEN 1 ELSE 0 END ;;
  }

  measure: sum_timeout {
    type: sum
    sql: CASE WHEN ${error_result_reason} = 'timeout' THEN 1 ELSE 0 END ;;
  }

  measure: sum_resources_exceeded {
    type: sum
    sql: CASE WHEN ${error_result_reason} = 'resourcesExceeded' THEN 1 ELSE 0 END ;;
  }

  measure: sum_other_errors {
    type: sum
    sql: CASE WHEN ${error_result_reason} NOT IN ('stopped', 'timeout', 'resourcesExceeded') THEN 1 ELSE 0 END ;;
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

  measure: daily_slot_usage   {
    # this measure only work if we slice the data by day or filter for the last 24h only. otherwise we can rely on the usage_timeline view.
    type: sum
    sql: SAFE_DIVIDE(${total_slot_ms}, (1000 * 60 * 60 * 24)) ;;
    value_format_name: decimal_2
  }

  measure: sum_shuffle_terabytes_spilled {
    type: sum
    sql: ${shuffle_terabytes_spilled} ;;
    value_format_name: decimal_2
  }

  measure: count_jobs_vs_threshold {
    type:  number
    sql: CASE WHEN (${count_jobs}>${thresholds.threshold_count_jobs} AND ${thresholds.slo_breach_count_jobs} = 1) THEN 2 WHEN ${count_jobs}>${thresholds.threshold_count_jobs} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/14?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/14?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/14?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_count_jobs._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ count_jobs._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ count_jobs._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ count_jobs._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: sum_stopped_vs_threshold {
    type: number
    sql: CASE WHEN (${sum_stopped}>${thresholds.threshold_sum_stopped} AND ${thresholds.slo_breach_sum_stopped} = 1) THEN 2 WHEN ${sum_stopped}>${thresholds.threshold_sum_stopped} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/13?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/13?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/13?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_sum_stopped._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ sum_stopped._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ sum_stopped._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_stopped._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: sum_timeout_vs_threshold {
    type: number
    sql: CASE WHEN (${sum_timeout}>${thresholds.threshold_sum_timeout} AND ${thresholds.slo_breach_sum_timeout} = 1) THEN 2 WHEN ${sum_timeout}>${thresholds.threshold_sum_timeout} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/12?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/12?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/12?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_sum_timeout._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ sum_timeout._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ sum_timeout._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_timeout._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: sum_resources_exceeded_vs_threshold {
    type: number
    sql: CASE WHEN (${sum_resources_exceeded}>${thresholds.threshold_sum_resources_exceeded} AND ${thresholds.slo_breach_sum_resources_exceeded} = 1) THEN 2 WHEN ${sum_resources_exceeded}>${thresholds.threshold_sum_resources_exceeded} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/8?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/8?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/8?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_sum_resources_exceeded._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ sum_resources_exceeded._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ sum_resources_exceeded._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_resources_exceeded._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: sum_other_errors_vs_threshold {
    type: number
    sql: CASE WHEN (${sum_other_errors}>${thresholds.threshold_sum_other_errors} AND ${thresholds.slo_breach_sum_other_errors} = 1) THEN 2 WHEN ${sum_other_errors}>${thresholds.threshold_sum_other_errors} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/7?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/7?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/7?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_sum_other_errors._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ sum_other_errors._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ sum_other_errors._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_other_errors._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: avg_job_duration_seconds_vs_threshold {
    type: number
    sql: CASE WHEN (${avg_job_duration_seconds}>${thresholds.threshold_avg_duration} AND ${thresholds.slo_breach_avg_duration} = 1) THEN 2 WHEN ${avg_job_duration_seconds}>${thresholds.threshold_avg_duration} THEN 1 ELSE 0 END ;;
    link: {
      label: "-- Show slowest jobs"
      url: "/looks/2?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    link: {
      label: "Show 14d time series"
      url: "/looks/4?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/4?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/4?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_avg_duration._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ avg_job_duration_seconds._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: median_job_duration_seconds_vs_threshold {
    type: number
    sql: CASE WHEN (${median_job_duration_seconds}>${thresholds.threshold_median_duration} AND ${thresholds.slo_breach_median_duration} = 1) THEN 2 WHEN ${median_job_duration_seconds}>${thresholds.threshold_median_duration} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/11?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/11?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/11?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_median_duration._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ median_job_duration_seconds._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ median_job_duration_seconds._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ median_job_duration_seconds._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: daily_slot_usage_vs_threshold   {
    type: number
    sql: CASE WHEN (${daily_slot_usage}>${thresholds.threshold_slot_usage} AND ${thresholds.slo_breach_slot_usage} = 1) THEN 2 WHEN ${daily_slot_usage}>${thresholds.threshold_slot_usage} THEN 1 ELSE 0 END ;;
    link: {
      label: "-- Show 24h time series"
      url: "/looks/5?&f[usage_timeline.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    link: {
      label: "Show 14d time series"
      url: "/looks/9?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/9?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/9?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_slot_usage._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ daily_slot_usage._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ daily_slot_usage._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ daily_slot_usage._rendered_value }}</p>
    {% endif %} ;;
  }

  measure: sum_shuffle_terabytes_spilled_vs_threshold {
    type: number
    sql: CASE WHEN (${sum_shuffle_terabytes_spilled}>${thresholds.threshold_shuffle_terabytes_spilled} AND ${thresholds.slo_breach_shuffle_terabytes_spilled} = 1) THEN 2 WHEN ${sum_shuffle_terabytes_spilled}>${thresholds.threshold_shuffle_terabytes_spilled} THEN 1 ELSE 0 END ;;
    link: {
      label: "Show 14d time series"
      url: "/looks/10?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+14+days"
    }
    link: {
      label: "Show 30d time series"
      url: "/looks/10?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+30+days"
    }
    link: {
      label: "Show 60d time series"
      url: "/looks/10?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}&f[jobs_by_organization.creation_time]=last+60+days"
    }
    link: {
      label: "6 months P90 of {{ thresholds.threshold_shuffle_terabytes_spilled._rendered_value }}"
      url: "/looks/3?&f[jobs_by_organization.reservation_id]={{ jobs_by_organization.reservation_id._value | url_encode }}"
    }
    html:
    {% if value == 2 %}
    <p style="color: black; background-color: lightcoral">{{ sum_shuffle_terabytes_spilled._rendered_value }}</p>
    {% elsif value == 1 %}
    <p style="color: black; background-color: orange">{{ sum_shuffle_terabytes_spilled._rendered_value }}</p>
    {% else %}
    <p style="color: black; background-color: palegreen">{{ sum_shuffle_terabytes_spilled._rendered_value }}</p>
    {% endif %} ;;
  }
}
