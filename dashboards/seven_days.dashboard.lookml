- name: add_a_unique_name_1643290225
  title: Untitled Visualization
  model: poc_model
  explore: jobs_by_organization
  type: looker_line
  fields: [jobs_by_organization.reservation_id, jobs_by_organization.creation_date,
    jobs_by_organization.avg_job_duration_seconds, thresholds.running_avg_job_duration_seconds]
  filters:
    jobs_by_organization.creation_time: 168 hours
    jobs_by_organization.reservation_id: bq-admin-spotify:EU.default
  sorts: [jobs_by_organization.creation_date desc]
  limit: 500
  column_limit: 50
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_view_names: false
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: true
  show_x_axis_ticks: true
  y_axis_scale_mode: linear
  x_axis_reversed: false
  y_axis_reversed: false
  plot_size_by_field: false
  trellis: ''
  stacking: ''
  limit_displayed_rows: false
  legend_position: center
  point_style: none
  show_value_labels: false
  label_density: 25
  x_axis_scale: auto
  y_axis_combined: true
  show_null_points: true
  interpolation: linear
  series_types: {}
  reference_lines: []
  show_row_numbers: true
  transpose: false
  truncate_text: true
  hide_totals: false
  hide_row_totals: false
  size_to_fit: true
  table_theme: white
  enable_conditional_formatting: false
  header_text_alignment: left
  header_font_size: 12
  rows_font_size: 12
  conditional_formatting_include_totals: false
  conditional_formatting_include_nulls: false
  defaults_version: 1
  hidden_fields: [jobs_by_organization.reservation_id]
