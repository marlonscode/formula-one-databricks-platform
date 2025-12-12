{{
    config(
        materialized="table"
    )
}}

select
    url,
    year
from {{ source('f1', 'f1_seasons') }}
