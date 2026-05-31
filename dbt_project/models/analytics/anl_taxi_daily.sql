select
  pickup_date,
  count(*) as trip_count,
  sum(total_amount) as total_revenue,
  avg(trip_distance) as avg_trip_distance,
  avg(total_amount) as avg_fare
from {{ ref('prc_trips') }}
group by pickup_date
