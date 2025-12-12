{{
    config(
        materialized="table"
    )
}}

select
    constructorresultsid,
    constructorid,
    raceid,
    status,
    points
from {{ source('f1', 'f1_constructor_results') }}
