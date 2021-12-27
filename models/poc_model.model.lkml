connection: "information_schema"

include: "/views/*.view.lkml"

explore: hourly_utilization {}
#explore: latest_slot_capacity {}
#explore: current_assignments {}
explore: reservation_utilization_week {}
#explore: daily_commitments{}
#explore: commitment_changes {}
#explore: current_commitments {}
explore: job_execution {}
explore: jobs_by_organization {
  join: reservation_capacity {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_by_organization.reservation_id} = ${reservation_capacity.reservation_id} ;;
  }
}
explore: job_error{}
