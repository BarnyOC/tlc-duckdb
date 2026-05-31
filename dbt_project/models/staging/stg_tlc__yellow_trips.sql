with source as (
  select *
  from read_parquet(
      '/data/raw/tlc/yellow/year=*/month=*/*.parquet',
      hive_partitioning = true
  )
),
renamed as (
  select
      vendorid as vendor_id,
      tpep_pickup_datetime as pickup_at,
      tpep_dropoff_datetime as dropoff_at,
      passenger_count,
      trip_distance,
      ratecodeid as rate_code_id,
      store_and_fwd_flag,
      pulocationid as pickup_location_id,
      dolocationid as dropoff_location_id,
      payment_type,
      fare_amount,
      extra,
      mta_tax,
      tip_amount,
      tolls_amount,
      improvement_surcharge,
      total_amount,
      year,
      month
  from source
)
select * from renamed
