{{
    config(
        materialized="table"
    )
}}

select
    air_temp.measurement_key,
    air_temp.datetime_minute,
    air_temp.track,
    round(avg(air_temp.air_temperature), 1) as air_temp,
    round(avg(track_temp.track_temperature), 1) as track_temp,
    round(avg(humidity.humidity), 1) as humidity,
    round(avg(air_pressure.air_pressure), 1) as air_pressure
from {{ ref('iot_air_temp_1min') }} as air_temp
inner join {{ ref('iot_track_temp_1min') }} as track_temp on air_temp.measurement_key = track_temp.measurement_key
inner join {{ ref('iot_humidity_1min') }} as humidity on air_temp.measurement_key = humidity.measurement_key
inner join {{ ref('iot_air_pressure_1min') }} as air_pressure on air_temp.measurement_key = air_pressure.measurement_key
group by air_temp.measurement_key, air_temp.datetime_minute, air_temp.track