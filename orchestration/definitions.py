from dagster import Definitions
from orchestration.assets.airbyte import get_airbyte_objects
from orchestration.assets.dbt import dbt_warehouse, dbt_warehouse_resource


airbyte_workspace, airbyte_assets = get_airbyte_objects()

defs = Definitions(
    assets=[*airbyte_assets, dbt_warehouse],
    resources={
        "airbyte": airbyte_workspace,
        "dbt_warehouse_resource": dbt_warehouse_resource
        }
)
