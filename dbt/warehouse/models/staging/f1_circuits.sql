{{
    config(
        materialized="table"
    )
}}

select
    circuitid,
    name,
    country,
    location,
    alt,
    lat,
    lng,
    circuitref,
    url
from {{ source('f1', 'f1_circuits') }}
