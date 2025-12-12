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
    nationality
from {{ source('f1', 'f1_drivers') }}
