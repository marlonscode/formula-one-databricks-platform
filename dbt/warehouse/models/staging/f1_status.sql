{{
    config(
        materialized="table"
    )
}}

select
    statusid,
    status,
    -- we are assuming that there is a CDC SCD2 system in place that provides valid_from and valid_to
    cast('1900-01-01' as timestamp) as valid_from,
    cast('9999-12-31' as timestamp) as valid_to
from {{ source("f1", "f1_status") }}
