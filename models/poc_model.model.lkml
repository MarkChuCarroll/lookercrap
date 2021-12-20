connection: "information_schema"

include: "/views/*.view.lkml"

explore: hourly_utilization {}
explore: latest_slot_capacity {}
explore: current_assignments {}
explore: reservation_utilization_week {}
explore: daily_commitments{}
explore: commitment_changes {}
explore: current_commitments {}
