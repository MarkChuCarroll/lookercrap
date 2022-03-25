view: thresholds {
  derived_table: {
    interval_trigger: "24 hours"
    sql: SELECT
          reservation_id,
          threshold_count_jobs,
          threshold_sum_stopped,
          threshold_sum_timeout,
          threshold_sum_resources_exceeded,
          threshold_sum_other_errors,
          threshold_avg_duration,
          threshold_median_duration,
          threshold_slot_usage,
          threshold_shuffle_terabytes_spilled,
          CASE WHEN SUM(CASE WHEN daily_count_jobs>threshold_count_jobs THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_count_jobs, -- Check metric against threshold and count if all 7 days are in breach
          CASE WHEN SUM(CASE WHEN daily_sum_stopped>threshold_sum_stopped THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_sum_stopped,
          CASE WHEN SUM(CASE WHEN daily_sum_timeout>threshold_sum_timeout THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_sum_timeout,
          CASE WHEN SUM(CASE WHEN daily_sum_resources_exceeded>threshold_sum_resources_exceeded THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_sum_resources_exceeded,
          CASE WHEN SUM(CASE WHEN daily_sum_other_errors>threshold_sum_other_errors THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_sum_other_errors,
          CASE WHEN SUM(CASE WHEN daily_avg_duration>threshold_avg_duration THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_avg_duration,
          CASE WHEN SUM(CASE WHEN daily_median_duration>threshold_median_duration THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_median_duration,
          CASE WHEN SUM(CASE WHEN daily_slot_usage>threshold_slot_usage THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_slot_usage,
          CASE WHEN SUM(CASE WHEN daily_shuffle_terabytes_spilled>threshold_shuffle_terabytes_spilled THEN 1 ELSE 0 END) = 7 THEN 1 ELSE 0 END AS slo_breach_shuffle_terabytes_spilled
          FROM
          (
            SELECT
            reservation_id,
            day,
            daily_count_jobs,
            daily_sum_stopped,
            daily_sum_timeout,
            daily_sum_resources_exceeded,
            daily_sum_other_errors,
            daily_avg_duration,
            daily_median_duration,
            daily_slot_usage,
            daily_shuffle_terabytes_spilled,
            ROUND(PERCENTILE_CONT(daily_count_jobs, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_count_jobs, -- Calculate 6 months P90 of the different metrics
            ROUND(PERCENTILE_CONT(daily_sum_stopped, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_sum_stopped,
            ROUND(PERCENTILE_CONT(daily_sum_timeout, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_sum_timeout,
            ROUND(PERCENTILE_CONT(daily_sum_resources_exceeded, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_sum_resources_exceeded,
            ROUND(PERCENTILE_CONT(daily_sum_other_errors, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_sum_other_errors,
            ROUND(PERCENTILE_CONT(daily_avg_duration, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_avg_duration,
            ROUND(PERCENTILE_CONT(daily_median_duration, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_median_duration,
            ROUND(PERCENTILE_CONT(daily_slot_usage, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_slot_usage,
            ROUND(PERCENTILE_CONT(daily_shuffle_terabytes_spilled, 0.9) OVER (PARTITION BY reservation_id)) AS threshold_shuffle_terabytes_spilled
          FROM
          (
            SELECT
            reservation_id,
            EXTRACT(DATE from jbo.creation_time) AS day,
            COUNT(job_id) AS daily_count_jobs, -- Calculate daily aggregates of all metrics
            SUM(CASE WHEN error_result.reason = 'stopped' THEN 1 ELSE 0 END) AS daily_sum_stopped,
            SUM(CASE WHEN error_result.reason = 'timeout' THEN 1 ELSE 0 END) AS daily_sum_timeout,
            SUM(CASE WHEN error_result.reason = 'resourcesExceeded' THEN 1 ELSE 0 END) AS daily_sum_resources_exceeded,
            SUM(CASE WHEN error_result.reason NOT IN ('stopped', 'timeout', 'resourcesExceeded') THEN 1 ELSE 0 END) AS daily_sum_other_errors,
            ROUND(AVG(TIMESTAMP_DIFF(end_time, start_time, SECOND))) AS daily_avg_duration,
            APPROX_QUANTILES(TIMESTAMP_DIFF(end_time, start_time, SECOND), 100)[OFFSET(50)] AS daily_median_duration,
            ROUND(SAFE_DIVIDE(SUM(total_slot_ms), (1000 * 60 * 60 * 24))) AS daily_slot_usage,
            ROUND(SUM((SELECT SUM(shuffle_output_bytes_spilled)/(1000*1000*1000*1000) FROM UNNEST(job_stages)))) AS daily_shuffle_terabytes_spilled
            FROM `region-eu.INFORMATION_SCHEMA.JOBS_BY_ORGANIZATION` jbo
            WHERE jbo.creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 180 DAY) AND CURRENT_TIMESTAMP() -- Get all 6 months of data
            GROUP BY reservation_id, day
          )
          )
          WHERE day BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) -- 7 days in the past from yesterday
          GROUP BY reservation_id, threshold_count_jobs, threshold_sum_stopped, threshold_sum_timeout, threshold_sum_resources_exceeded, threshold_sum_other_errors,
          threshold_avg_duration, threshold_median_duration, threshold_slot_usage, threshold_shuffle_terabytes_spilled
          ;;
  }

  dimension: reservation_id   {
    primary_key: yes
    type: string
    sql: ${TABLE}.reservation_id ;;
  }

  # Use of SUM type to avoid Looker group by errors
  measure: threshold_count_jobs   {
    type: sum
    sql: ${TABLE}.threshold_count_jobs ;;
  }

  measure: slo_breach_count_jobs  {
    type: sum
    sql: ${TABLE}.slo_breach_count_jobs ;;
  }

  measure: threshold_sum_stopped   {
    type: sum
    sql: ${TABLE}.threshold_sum_stopped ;;
  }

  measure: slo_breach_sum_stopped   {
    type: sum
    sql: ${TABLE}.slo_breach_sum_stopped ;;
  }

  measure: threshold_sum_timeout   {
    type: sum
    sql: ${TABLE}.threshold_sum_timeout ;;
  }

  measure: slo_breach_sum_timeout   {
    type: sum
    sql: ${TABLE}.slo_breach_sum_timeout ;;
  }

  measure: threshold_sum_resources_exceeded   {
    type: sum
    sql: ${TABLE}.threshold_sum_resources_exceeded ;;
  }

  measure: slo_breach_sum_resources_exceeded   {
    type: sum
    sql: ${TABLE}.slo_breach_sum_resources_exceeded ;;
  }

  measure: threshold_sum_other_errors   {
    type: sum
    sql: ${TABLE}.threshold_sum_other_errors ;;
  }

  measure: slo_breach_sum_other_errors   {
    type: sum
    sql: ${TABLE}.slo_breach_sum_other_errors ;;
  }

  measure: threshold_avg_duration   {
    type: sum
    sql: ${TABLE}.threshold_avg_duration ;;
  }

  measure: slo_breach_avg_duration   {
    type: sum
    sql: ${TABLE}.slo_breach_avg_duration ;;
  }

  measure: threshold_median_duration   {
    type: sum
    sql: ${TABLE}.threshold_median_duration ;;
  }

  measure: slo_breach_median_duration   {
    type: sum
    sql: ${TABLE}.slo_breach_median_duration ;;
  }

  measure: threshold_slot_usage   {
    type: sum
    sql: ${TABLE}.threshold_slot_usage ;;
  }

  measure: slo_breach_slot_usage   {
    type: sum
    sql: ${TABLE}.slo_breach_slot_usage ;;
  }

  measure: threshold_shuffle_terabytes_spilled   {
    type: sum
    sql: ${TABLE}.threshold_shuffle_terabytes_spilled ;;
  }

  measure: slo_breach_shuffle_terabytes_spilled   {
    type: sum
    sql: ${TABLE}.slo_breach_shuffle_terabytes_spilled ;;
  }

}
