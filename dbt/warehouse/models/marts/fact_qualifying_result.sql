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

qualifying as (
select
    qualifyid,
    raceid,
    driverid,
    constructorid,
    q1,
    q2,
    q3,
    position
from {{ ref("f1_qualifying") }}
)


select
    {{ dbt_utils.generate_surrogate_key(['qualifying.qualifyid']) }} as qualifying_key,
    {{ dbt_utils.generate_surrogate_key(['races.raceid']) }} as race_key,
    {{ dbt_utils.generate_surrogate_key(['qualifying.driverid']) }} as driver_key,
    {{ dbt_utils.generate_surrogate_key(['qualifying.constructorid']) }} as constructor_key,
    {{ dbt_utils.generate_surrogate_key(['races.circuitid']) }} as circuit_key,
    qualifying.q1,
    qualifying.q2,
    qualifying.q3,
    qualifying.position,
    races.race_date
from qualifying inner join races on qualifying.raceid = races.raceid
