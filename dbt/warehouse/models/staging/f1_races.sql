{{
    config(
        materialized="table"
    )
}}

select
    url,
    {{ safe_cast('date', 'date') }} as date,
    name as race_name,
    time,
    cast(year as int) as year,
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
