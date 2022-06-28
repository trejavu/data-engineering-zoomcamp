{{ config(materialized='view') }}

with tripdata as 
(
  select *,
    row_number() over(partition by dispatching_base_num, pickup_datetime) as rn
  from {{ source('staging','fhv_tripdata') }} 
)
select
    -- identifiers
    {{ dbt_utils.surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} as tripid,
    dispatching_base_num,
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    cast(PULocationID as integer) as pickup_locationid,
    cast(DOLocationID as integer) as dropoff_locationid,
    SR_Flag
from tripdata
where rn = 1


-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
