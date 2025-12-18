{{
    config(
        materialized="table"
    )
}}

select
    air_temp.measurement_key as measurement_key,
    air_temp.datetime_minute as datetime_minute,
    air_temp.track as track,
    round(avg(air_temp.air_temperature), 1) as air_temp,
    round(avg(track_temp.track_temperature), 1) as track_temp,
    round(avg(humidity.humidity), 1) as humidity,
    round(avg(air_pressure.air_pressure), 1) as air_pressure
from {{ ref('iot_air_temp_1min') }} as air_temp
join {{ ref('iot_track_temp_1min') }} as track_temp using (measurement_key)
join {{ ref('iot_humidity_1min') }} as humidity using (measurement_key)
join {{ ref('iot_air_pressure_1min') }} as air_pressure using (measurement_key)
group by air_temp.measurement_key, air_temp.datetime_minute, air_temp.track