{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['raceid']) }} as race_key,
    race_name,
    race_date,
    time,
    race_year,
    round
from {{ ref("f1_races") }}
