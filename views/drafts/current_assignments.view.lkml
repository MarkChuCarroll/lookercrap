view: current_assignments {
   derived_table: {
     sql: SELECT
          acp.assignment_id,
          acp.project_id,
          acp.reservation_name,
          acp.job_type,
          acp.assignee_id,
          acp.assignee_type
        FROM
          `bq-admin-spotify.region-{% parameter region %}.INFORMATION_SCHEMA.ASSIGNMENT_CHANGES_BY_PROJECT` AS acp
        -- Join to obtain the current slot capacities
        GROUP BY
          acp.assignment_id,
          acp.project_id,
          acp.reservation_name,
          acp.job_type,
          acp.assignee_id,
          acp.assignee_type
        -- In order to return only active assignments (i.e. ones that have not been
        -- deleted) we select only assignments that have one entry in this table.
        -- Assignments that have been deleted have two entries in this table,
        -- one where the action is CREATE and one where the action is DELETE.
        HAVING COUNT(assignment_id) = 1
       ;;
  }

  parameter: region {
    type: unquoted
    allowed_value: { value: "eu" }
    allowed_value: { value: "us" }
  }

  dimension: assignment_id {
    type: string
    sql: ${TABLE}.assignment_id ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: reservation_name {
    type: string
    sql: ${TABLE}.reservation_name ;;
  }

  dimension: job_type {
    type: string
    sql: ${TABLE}.job_type ;;
  }

  dimension: assignee_id {
    type: string
    sql: ${TABLE}.assignee_id ;;
  }

  dimension: assignee_type {
    type: string
    sql: ${TABLE}.assignee_type ;;
  }


}
