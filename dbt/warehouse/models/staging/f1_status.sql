{{
    config(
        materialized="table"
    )
}}

select
    statusid,
    status,
    dbt_valid_from,
    dbt_valid_to
from {{ ref("f1_status_history") }}
