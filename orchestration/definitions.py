from dagster import Definitions
from orchestration.assets.airbyte import airbyte_assets, airbyte_workspace
from orchestration.assets.dbt import dbt_warehouse, dbt_warehouse_resource


defs = Definitions(
    assets=[*airbyte_assets, dbt_warehouse],
    resources={
        "airbyte": airbyte_workspace,
        "dbt_warehouse_resource": dbt_warehouse_resource
        }
)
