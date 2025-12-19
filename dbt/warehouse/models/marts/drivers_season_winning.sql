{{
    config(
        materialized="table"
    )
}}

with base_table as (
select
    season,
    concat(forename, ' ', surname) as driver,
    constructor_name as team,
    round(sum(points)) as total_points,
    dense_rank() over (partition by season order by sum(points) desc) as season_rank
from {{ ref("fact_race_result") }} as race_result
inner join {{ ref("dim_driver") }} as dim_driver on race_result.driver_key = dim_driver.driver_key
inner join {{ ref("dim_constructor") }} as dim_constructor on race_result.constructor_key = dim_constructor.constructor_key
group by season, driver, constructor_name
qualify season_rank = 1
order by season desc, total_points desc
)

select
    season,
    driver,
    team,
    total_points
from base_table