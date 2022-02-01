- name: add_a_unique_name_1643290664
  title: Untitled Visualization
  model: poc_model
  explore: jobs_by_organization
  type: looker_grid
  fields: [jobs_by_organization.reservation_id, jobs_by_organization.project_id, jobs_by_organization.job_id,
    jobs_by_organization.job_duration_seconds]
  filters:
    jobs_by_organization.reservation_id: bq-admin-spotify:EU.tier-one
    jobs_by_organization.creation_time: 24 hours
  sorts: [jobs_by_organization.job_duration_seconds desc]
  limit: 50
  column_limit: 50
  show_view_names: false
  show_row_numbers: true
  transpose: false
  truncate_text: true
  hide_totals: false
  hide_row_totals: false
  size_to_fit: true
  table_theme: white
  limit_displayed_rows: false
  enable_conditional_formatting: false
  header_text_alignment: left
  header_font_size: '12'
  rows_font_size: '12'
  conditional_formatting_include_totals: false
  conditional_formatting_include_nulls: false
  show_sql_query_menu_options: false
  show_totals: true
  show_row_totals: true
  series_cell_visualizations:
    jobs_by_organization.avg_job_duration_seconds_vs_threshold:
      is_active: false
  defaults_version: 1
