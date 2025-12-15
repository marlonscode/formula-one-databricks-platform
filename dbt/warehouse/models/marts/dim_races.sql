{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['raceid']) }} as race_key,
    name,
    date,
    time,
    year,
    round
from {{ ref("f1_races") }}
