{{
    config(
        materialized="table"
    )
}}

with races as (
select
    raceid,
    circuitid,
    race_date,
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
    points,
    fastestlap,
    fastestlaptime,
    positionorder
from {{ ref("f1_sprint_results") }}
)

select
    {{ dbt_utils.generate_surrogate_key(['sprint_results.resultid']) }} as sprint_result_key,
    {{ dbt_utils.generate_surrogate_key(['races.raceid']) }} as race_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.driverid']) }} as driver_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.constructorid']) }} as constructor_key,
    {{ dbt_utils.generate_surrogate_key(['races.circuitid']) }} as circuit_key,
    {{ dbt_utils.generate_surrogate_key(['sprint_results.statusid']) }} as status_key,
    sprint_results.fastestlap,
    sprint_results.fastestlaptime,
    sprint_results.positionorder
from sprint_results inner join races on sprint_results.raceid = races.raceid
