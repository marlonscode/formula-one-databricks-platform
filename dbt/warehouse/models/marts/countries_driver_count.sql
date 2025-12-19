{{
    config(
        materialized="table"
    )
}}

select
    driver_nationality as nationality,
    count(distinct race_result.driver_key) as driver_count
from {{ ref("fact_race_result") }} as race_result
inner join {{ ref("dim_driver") }} as dim_driver on race_result.driver_key = dim_driver.driver_key
group by driver_nationality
order by driver_count desc