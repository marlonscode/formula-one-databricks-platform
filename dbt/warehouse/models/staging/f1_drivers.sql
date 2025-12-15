{{
    config(
        materialized="table"
    )
}}

select
    dob,
    url,
    code,
    number,
    surname,
    driverid,
    forename,
    driverref,
    nationality as driver_nationality
from {{ source('f1', 'f1_drivers') }}
