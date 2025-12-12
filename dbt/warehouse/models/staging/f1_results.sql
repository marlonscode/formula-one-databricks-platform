{{
    config(
        materialized="table"
    )
}}

select
    grid,
    laps,
    rank,
    time,
    number,
    points,
    raceid,
    driverid,
    position,
    resultid,
    statusid,
    fastestlap,
    milliseconds,
    positiontext,
    constructorid,
    positionorder
from {{ source('f1', 'f1_results') }}
