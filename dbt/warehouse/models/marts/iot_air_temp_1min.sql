{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['datetime_minute']) }} as air_temp_key,
    datetime_minute,
    track,
    air_temperature
from {{ ref("iot_air_temp") }}