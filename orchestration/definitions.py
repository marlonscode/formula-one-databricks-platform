from dagster import Definitions
from orchestration.assets.airbyte import airbyte_assets, airbyte_workspace

defs = Definitions(
    assets=[*airbyte_assets],
    resources={
        "airbyte": airbyte_workspace
        }
)
