{{
    config(
        materialized="table"
    )
}}

select
    datetime,
    track,
    humidity
from {{ source('f1', 'iot_humidity') }}
