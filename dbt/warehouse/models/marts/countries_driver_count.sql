{{
    config(
        materialized="table"
    )
}}

select
    driver_nationality as nationality,
    count(distinct driver_key) as driver_count
from {{ ref("fact_race_result") }}
inner join {{ ref("dim_driver") }} using (driver_key)
group by driver_nationality
order by driver_count desc