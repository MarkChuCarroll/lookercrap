connection: "information_schema"

include: "/views/*.view.lkml"

explore: jobs_by_organization {
  join: job_stages {
    sql: LEFT JOIN UNNEST(job_stages) as job_stages ;;
    relationship: one_to_many
  }
  join: reservation_capacity {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_by_organization.reservation_id} = ${reservation_capacity.reservation_id} ;;
  }
  join: thresholds {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_by_organization.reservation_id} = ${thresholds.reservation_id} ;;
  }
}
