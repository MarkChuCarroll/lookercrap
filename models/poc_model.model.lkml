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
  # Repeated nested object
  join: jobs_by_organization_job_stages {
    sql: LEFT JOIN UNNEST(jobs_by_organization.job_stages) as jobs_by_organization_job_stages ;;
    relationship: one_to_many
  }
}
explore: job_error{}
