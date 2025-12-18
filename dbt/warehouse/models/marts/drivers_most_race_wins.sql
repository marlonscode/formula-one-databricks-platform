{{
    config(
        materialized="table"
    )
}}

select
    concat(forename, ' ', surname) as driver,
    count(finishing_position) as race_wins
from {{ ref("fact_race_result") }}
inner join {{ ref("dim_driver") }} using (driver_key)
where finishing_position = '1'
group by driver
order by race_wins desc