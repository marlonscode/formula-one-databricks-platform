{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['statusid']) }} as status_key,
    statusid,
    status
from {{ ref("f1_status") }}
