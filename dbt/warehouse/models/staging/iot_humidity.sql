{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    date_trunc('minute', timestamp(datetime)) as datetime_minute,
    track,
    humidity
from {{ source('f1', 'iot_humidity') }}
