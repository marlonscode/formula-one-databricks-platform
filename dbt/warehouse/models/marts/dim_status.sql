{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['statusid']) }} as status_key,
    statusid,
    status,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref("f1_status") }}
