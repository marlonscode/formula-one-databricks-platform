{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['datetime_minute']) }} as air_pressure_key,
    datetime_minute,
    track,
    air_pressure
from {{ ref("iot_air_pressure") }}