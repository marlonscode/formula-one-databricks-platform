{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['year']) }} as season_key,
    year
from {{ ref("f1_seasons") }}
