{{
    config(
        materialized="table"
    )
}}

select
    lap,
    stop,
    time,
    raceid,
    driverid,
    duration,
    milliseconds
from {{ source('f1', 'f1_pit_stops') }}
