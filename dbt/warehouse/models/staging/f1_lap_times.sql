{{
    config(
        materialized="table"
    )
}}

select
    lap,
    time,
    raceid,
    driverid,
    position,
    milliseconds
from {{ source('f1', 'f1_lap_times') }}
