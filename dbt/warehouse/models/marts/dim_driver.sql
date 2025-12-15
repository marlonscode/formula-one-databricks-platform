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
    driver_nationality
from {{ ref("f1_drivers") }}
