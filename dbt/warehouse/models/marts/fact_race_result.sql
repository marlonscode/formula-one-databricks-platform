{{
    config(
        materialized="table"
    )
}}

with races as (
select
    raceid,
    circuitid,
    date as race_date,
    year as race_year,
    race_name,
    round
from {{ ref("f1_races") }}
),

results as (
select
    resultid,
    raceid,
    driverid,
    constructorid,
    statusid,
    grid as starting_grid_position,
    position as finishing_position,
    laps as laps_completed,
    points
from {{ ref("f1_results") }}
)

select
    {{ dbt_utils.generate_surrogate_key(['results.resultid']) }} as race_result_key,
    {{ dbt_utils.generate_surrogate_key(['races.raceid']) }} as race_key,
    {{ dbt_utils.generate_surrogate_key(['results.driverid']) }} as driver_key,
    {{ dbt_utils.generate_surrogate_key(['results.constructorid']) }} as constructor_key,
    {{ dbt_utils.generate_surrogate_key(['races.circuitid']) }} as circuit_key,
    status.status_key,
    results.starting_grid_position,
    results.finishing_position,
    results.laps_completed,
    results.points,
    races.race_year as season,
    races.race_date
from results
inner join races on results.raceid = races.raceid
inner join {{ ref("dim_status") }} as status
    on results.statusid = status.statusid
    and cast(races.race_date as timestamp) < coalesce(status.valid_to, cast('9999-12-31' as timestamp))
