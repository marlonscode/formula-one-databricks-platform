{{
    config(
        materialized="table"
    )
}}

select
    {{ dbt_utils.star(from=ref('fact_race_result'), relation_alias='fact_race_result', except=["race_key", "driver_key", "constructor_key", "circuit_key", "status_key"]) }},
    {{ dbt_utils.star(from=ref('dim_race'), relation_alias='dim_race', except=["race_key", "race_date", "race_year"]) }},
    {{ dbt_utils.star(from=ref('dim_circuit'), relation_alias='dim_circuit', except=["circuit_key"]) }},
    {{ dbt_utils.star(from=ref('dim_driver'), relation_alias='dim_driver', except=["driver_key"]) }},
    {{ dbt_utils.star(from=ref('dim_constructor'), relation_alias='dim_constructor', except=["constructor_key"]) }},
    {{ dbt_utils.star(from=ref('dim_status'), relation_alias='dim_status', except=["status_key", "last_update", "film_title"]) }}
from {{ ref('fact_race_result') }} as fact_race_result
inner join {{ ref('dim_race') }} as dim_race on fact_race_result.race_key = dim_race.race_key
inner join {{ ref('dim_circuit') }} as dim_circuit on fact_race_result.circuit_key = dim_circuit.circuit_key
inner join {{ ref('dim_driver') }} as dim_driver on fact_race_result.driver_key = dim_driver.driver_key
inner join {{ ref('dim_constructor') }} as dim_constructor on fact_race_result.constructor_key = dim_constructor.constructor_key
inner join {{ ref('dim_status') }} as dim_status on fact_race_result.status_key = dim_status.status_key