{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['constructorid']) }} as constructor_key,
    name,
    nationality
from {{ ref("f1_constructors") }}
