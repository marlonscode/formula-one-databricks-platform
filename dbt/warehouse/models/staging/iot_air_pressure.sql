{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    track,
    air_pressure
from {{ source('f1', 'iot_air_pressure') }}
