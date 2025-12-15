{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['circuitid']) }} as circuit_key,
    circuit_name,
    circuitref,
    location,
    country,
    alt,
    lat,
    lng
from {{ ref("f1_circuits") }}
