connection: "information_schema"

include: "/views/*.view.lkml"

explore: hourly_utilization {}
explore: latest_slot_capacity {}
