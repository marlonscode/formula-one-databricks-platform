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
    dense_rank() over (partition by season order by sum(points) desc) as rank
from {{ ref("fact_race_result") }}
inner join {{ ref("dim_driver") }} using (driver_key)
inner join databricks_platform.dev_marts.dim_constructor using (constructor_key)
group by season, driver, constructor_name
qualify rank = 1
order by season desc, total_points desc
)

select
    season,
    driver,
    team,
    total_points
from base_table