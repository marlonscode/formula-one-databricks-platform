{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['statusid']) }} as status_key,
    status
from {{ ref("f1_status") }}
