-- AIModified:2026-06-01T07:29:04Z
with trips as (
  select * from {{ ref('stg_tlc__yellow_trips') }}
),
cleaned as (
  select
      *,
      date_trunc('day', pickup_at) as pickup_date,
      md5(
        coalesce(cast(pickup_at as varchar), '') || '|' ||
        coalesce(cast(dropoff_at as varchar), '') || '|' ||
        coalesce(cast(pickup_location_id as varchar), '') || '|' ||
        coalesce(cast(total_amount as varchar), '')
      ) as trip_sk,
    row_number() over(partition by trip_sk) row_version
  from trips
  where pickup_at is not null
    and dropoff_at is not null
    and total_amount >= 0
    and trip_distance > 0
)
select * from cleaned where row_version = 1
