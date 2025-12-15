{{
    config(
        materialized="table"
    )
}}

select
    constructorid,
    constructorref,
    name as constructor_name,
    nationality as constructor_nationality,
    url
from {{ source('f1', 'f1_constructors') }}
