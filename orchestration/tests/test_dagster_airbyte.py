import os
from orchestration.assets.airbyte import connections_list


def test_connections_list_not_empty():
    actual = len(connections_list) > 0
    expected = True
    assert actual == expected
