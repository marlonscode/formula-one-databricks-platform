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
    cast(air_temperature as double) as air_temperature
from {{ source('f1', 'iot_air_temp') }}

{% if is_incremental() %}
where datetime > (select max(datetime) from {{ this }})
{% endif %}
