{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    date_trunc('minute', timestamp(datetime)) as datetime_minute,
    track,
    air_pressure
from {{ source('f1', 'iot_air_pressure') }}
