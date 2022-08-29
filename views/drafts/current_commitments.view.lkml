view: current_commitments {
  derived_table: {
    sql: SELECT
          *
        FROM
          `bq-admin-spotify.region-eu.INFORMATION_SCHEMA.CAPACITY_COMMITMENTS_BY_PROJECT`
       ;;
  }

  dimension: project_id   {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: capacity_commitment_id   {
    type: string
    sql: ${TABLE}.capacity_commitment_id ;;
  }

  dimension: commitment_plan   {
    type: string
    sql: ${TABLE}.commitment_plan ;;
  }

  dimension: state   {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: slot_count   {
    type: number
    sql: ${TABLE}.slot_count ;;
  }

}
