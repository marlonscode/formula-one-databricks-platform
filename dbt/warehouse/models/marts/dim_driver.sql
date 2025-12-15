{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['driverid']) }} as driver_key,
    forename,
    surname,
    dob,
    nationality
from {{ ref("f1_drivers") }}
