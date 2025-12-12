{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    track,
    track_temperature
from {{ source('f1', 'iot_track_temp') }}
