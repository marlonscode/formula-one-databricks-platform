{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['datetime_minute']) }} as humidity_key,
    datetime_minute,
    track,
    humidity
from {{ ref("iot_humidity") }}