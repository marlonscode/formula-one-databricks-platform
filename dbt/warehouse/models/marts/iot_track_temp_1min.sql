{{
    config(
        materialized="incremental",
        unique_key=["datetime_minute", "track"],
        incremental_strategy="delete+insert"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['datetime_minute', 'track']) }} as measurement_key,
    datetime_minute,
    track,
    track_temperature
from {{ ref("iot_track_temp") }}

{% if is_incremental() %}
where datetime_minute > (select max(datetime_minute) from {{ this }})
{% endif %}