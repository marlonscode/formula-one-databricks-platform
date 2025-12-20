from dagster import Definitions
from analytics.assets.airbyte import airbyte_assets, airbyte_workspace

defs = Definitions(
    assets=[*airbyte_assets],
    resources={
        "airbyte": airbyte_workspace
        }
)
