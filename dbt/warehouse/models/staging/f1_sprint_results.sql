{{
    config(
        materialized="table"
    )
}}

select
    grid,
    laps,
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
    positionorder,
    fastestlaptime
from {{ source('f1', 'f1_sprint_results') }}
