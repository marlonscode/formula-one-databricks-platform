{{
    config(
        materialized="table"
    )
}}

select
    constructorstandingsid,
    constructorid,
    raceid,
    position,
    positiontext,
    points,
    wins
from {{ source('f1', 'f1_constructor_standings') }}
