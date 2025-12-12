{{
    config(
        materialized="table"
    )
}}

select
    constructorid,
    constructorref,
    name,
    nationality,
    url
from {{ source('f1', 'f1_constructors') }}
