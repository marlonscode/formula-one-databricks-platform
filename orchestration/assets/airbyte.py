from dagster import EnvVar, AutomationCondition, AssetSpec, AssetKey
from dagster_airbyte import AirbyteWorkspace, build_airbyte_assets_definitions, DagsterAirbyteTranslator, AirbyteConnectionTableProps

class CustomDagsterAirbyteTranslator(DagsterAirbyteTranslator):
    def get_asset_spec(self, props: AirbyteConnectionTableProps) -> AssetSpec:
        default_spec = super().get_asset_spec(props)
        return default_spec.replace_attributes(
            group_name="airbyte_assets",
            key=AssetKey(["f1", props.table_name]),
            automation_condition=AutomationCondition.on_cron(cron_schedule="* * * * *")
        )

connections_list = [
    "pg_to_db",
    "iot_ap_to_db",
    "iot_at_to_db",
    "iot_hu_to_db",
    "iot_tt_to_db",
    ]

# Load all assets from your Airbyte workspace
airbyte_assets = build_airbyte_assets_definitions(
    workspace=airbyte_workspace,
    dagster_airbyte_translator=CustomDagsterAirbyteTranslator(),
    connection_selector_fn=lambda connection: connection.name in connections_list
)
