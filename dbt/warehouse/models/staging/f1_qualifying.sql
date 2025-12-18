{{
    config(
        materialized="table"
    )
}}

select
    qualifyid,
    raceid,
    driverid,
    constructorid,
    position,
    q1,
    q2,
    q3
from {{ source('f1', 'f1_qualifying') }}
