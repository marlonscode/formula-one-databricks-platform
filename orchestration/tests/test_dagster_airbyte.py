import os
from orchestration.assets.airbyte import connections_list


def test_connections_list_not_empty():
    # Set dummy environment variables for testing
    os.environ["AIRBYTE_WORKSPACE_ID"] = "dummy_workspace"
    os.environ["AIRBYTE_CLIENT_ID"] = "dummy_client"
    os.environ["AIRBYTE_CLIENT_SECRET"] = "dummy_secret"
    actual = len(connections_list) > 0
    expected = True
    assert actual == expected
