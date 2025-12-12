{{
    config(
        materialized="table"
    )
}}

select
    driverstandingsid,
    raceid,
    driverid,
    wins,
    points,
    position,
    positiontext
from {{ source('f1', 'f1_driver_standings') }}
