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
    race_name,
    round
from {{ ref("f1_races") }}
),

sprint_results as (
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
from {{ ref("f1_sprint_results") }}
)


select
    {{ dbt_utils.generate_surrogate_key(['sprint_results.resultid']) }} as sprint_result_key,
    {{ dbt_utils.generate_surrogate_key(['races.raceid']) }} as race_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.driverid']) }} as driver_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.constructorid']) }} as constructor_key,
    {{ dbt_utils.generate_surrogate_key(['races.circuitid']) }} as circuit_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.statusid']) }} as status_key,
    sprint_results.starting_grid_position,
    sprint_results.finishing_position,
    sprint_results.laps_completed,
    sprint_results.points,
    races.race_date
from sprint_results inner join races on sprint_results.raceid = races.raceid
