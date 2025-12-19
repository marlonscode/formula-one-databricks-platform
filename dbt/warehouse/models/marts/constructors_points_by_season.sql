{{
    config(
        materialized="table"
    )
}}

select
    season,
    constructor_name,
    sum(points) as total_points
from {{ ref("fact_race_result") }} as race_result
inner join {{ ref("dim_constructor") }} as dim_constructor on race_result.constructor_key = dim_constructor.constructor_key
where season between 2005 and 2025
group by season, constructor_name
order by season asc, total_points desc