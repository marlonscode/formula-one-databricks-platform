{{
    config(
        materialized="incremental",
        unique_key=["datetime", "track"],
        incremental_strategy="delete+insert"
    )
}}

select
    datetime,
    date_trunc('minute', timestamp(datetime)) as datetime_minute,
    track,
    track_temperature
from {{ source('f1', 'iot_track_temp') }}

{% if is_incremental() %}
where datetime > (select max(datetime) from {{ this }})
{% endif %}
