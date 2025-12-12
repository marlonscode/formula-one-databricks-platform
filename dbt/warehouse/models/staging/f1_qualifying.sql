{{
    config(
        materialized="table"
    )
}}

select
    q1,
    q2,
    q3,
    number,
    raceid,
    driverid,
    position,
    qualifyid,
    constructorid
from {{ source('f1', 'f1_qualifying') }}
