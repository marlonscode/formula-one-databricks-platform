{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    date_trunc('minute', timestamp(datetime)) as datetime_minute,
    track,
    track_temperature
from {{ source('f1', 'iot_track_temp') }}
