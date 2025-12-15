{{
    config(
        materialized="table"
    )
}}

select
    circuitid,
    name as circuit_name,
    country,
    location,
    alt,
    lat,
    lng,
    circuitref,
    url
from {{ source('f1', 'f1_circuits') }}
