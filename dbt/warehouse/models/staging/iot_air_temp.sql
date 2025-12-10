{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    track,
    air_temperature
from {{ source('f1', 'iot_air_temp') }}
