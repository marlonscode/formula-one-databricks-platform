from dagster_airbyte import AirbyteWorkspace, build_airbyte_assets_definitions
import dagster as dg

# Connect to your OSS Airbyte instance
airbyte_workspace = AirbyteWorkspace(
    rest_api_base_url="http://ec2-54-206-100-192.ap-southeast-2.compute.amazonaws.com:8000/api/public/v1",
    configuration_api_base_url="http://ec2-54-206-100-192.ap-southeast-2.compute.amazonaws.com:8000/api/v1",
    workspace_id=dg.EnvVar("AIRBYTE_WORKSPACE_ID"),
    client_id=dg.EnvVar("AIRBYTE_CLIENT_ID"),
    client_secret=dg.EnvVar("AIRBYTE_CLIENT_SECRET"),
)

# Load all assets from your Airbyte workspace
airbyte_assets = build_airbyte_assets_definitions(workspace=airbyte_workspace)
