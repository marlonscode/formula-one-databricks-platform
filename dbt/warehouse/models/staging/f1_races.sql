{{
    config(
        materialized="table"
    )
}}

select
    url,
    date,
    name,
    time,
    year,
    round,
    raceid,
    fp1_date,
    fp1_time,
    fp2_date,
    fp2_time,
    fp3_date,
    fp3_time,
    circuitid,
    quali_date,
    quali_time
from {{ source('f1', 'f1_races') }}
