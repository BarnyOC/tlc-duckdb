with trips as (
  select * from {{ ref('stg_tlc__yellow_trips') }}
),
cleaned as (
  select
      *,
      date_trunc('day', pickup_at) as pickup_date
  from trips
  where pickup_at is not null
    and dropoff_at is not null
    and total_amount >= 0
    and trip_distance > 0
)
select * from cleaned
