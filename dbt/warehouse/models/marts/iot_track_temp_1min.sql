{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['datetime_minute']) }} as track_temp_key,
    datetime_minute,
    track,
    track_temperature
from {{ ref("iot_track_temp") }}