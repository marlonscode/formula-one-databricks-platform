{{
    config(
        materialized="table"
    )
}}

select
    statusid,
    status
from {{ source("f1", "f1_status") }}
