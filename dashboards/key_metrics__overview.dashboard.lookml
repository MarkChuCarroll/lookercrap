- dashboard: key_metrics__overview
  title: Key metrics - overview
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  elements:
  - title: Key metrics - Last 24 hours
    name: Key metrics - Last 24 hours
    model: poc_model
    explore: jobs_by_organization
    type: looker_grid
    fields: [jobs_by_organization.reservation_id, reservation_capacity.latest_capacity,
      thresholds.running_avg_job_duration_seconds, jobs_by_organization.average_slot_usage_last_24h,
      jobs_by_organization.reservation_utilization, jobs_by_organization.avg_job_duration_seconds_vs_threshold,
      jobs_by_organization.median_job_duration_seconds, jobs_by_organization.count_errors,
      job_stages.total_shuffle_output_terabytes, job_stages.total_shuffle_output_terabytes_spilled]
    filters:
      jobs_by_organization.creation_time: 24 hours
    sorts: [jobs_by_organization.average_slot_usage_last_24h desc]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '16'
    rows_font_size: '14'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    pinned_columns: {}
    column_order: [jobs_by_organization.reservation_id, reservation_capacity.latest_capacity,
      jobs_by_organization.average_slot_usage_last_24h, jobs_by_organization.reservation_utilization,
      jobs_by_organization.avg_job_duration_seconds_vs_threshold, jobs_by_organization.median_job_duration_seconds,
      jobs_by_organization.count_errors, job_stages.total_shuffle_output_terabytes,
      job_stages.total_shuffle_output_terabytes_spilled]
    show_totals: true
    show_row_totals: true
    series_labels:
      jobs_by_organization.reservation_id: Reservation
      reservation_capacity.latest_capacity: Current capacity
      jobs_by_organization.average_slot_usage_last_24h: Slots usage
      jobs_by_organization.avg_job_duration_seconds_vs_threshold: Average job duration
      jobs_by_organization.median_job_duration_seconds: Median job duration
      jobs_by_organization.count_errors: Errors
      job_stages.total_shuffle_output_terabytes: Shuffle output TB
      job_stages.total_shuffle_output_terabytes_spilled: Shuffle spilled TB
    series_column_widths:
      jobs_by_organization.weekly_reservation_utilization_based_on_latest_capacity: 184
      jobs_by_organization.avg_job_duration_seconds_vs_threshold: 120
      jobs_by_organization.reservation_id: 400
      reservation_capacity.latest_capacity: 100
      jobs_by_organization.average_slot_usage_last_24h: 120
      jobs_by_organization.reservation_utilization: 110
      jobs_by_organization.median_job_duration_seconds: 100
      jobs_by_organization.count_errors: 100
      job_stages.total_shuffle_output_terabytes: 100
      job_stages.total_shuffle_output_terabytes_spilled: 100
    series_cell_visualizations:
      jobs_by_organization.average_weekly_slot_usage:
        is_active: true
      jobs_by_organization.weekly_reservation_utilization_based_on_latest_capacity:
        is_active: false
      job_stages.total_shuffle_output_terabytes_spilled:
        is_active: false
      jobs_by_organization.reservation_utilization:
        is_active: false
    series_text_format:
      jobs_by_organization.reservation_utilization:
        bold: true
      jobs_by_organization.reservation_id:
        fg_color: "#000000"
        bold: true
    header_font_color: "#000000"
    conditional_formatting: []
    truncate_column_names: false
    defaults_version: 1
    hidden_fields: [thresholds.running_avg_job_duration_seconds]
    series_types: {}
    listen: {}
    row: 0
    col: 0
    width: 24
    height: 14
