import os
from pathlib import Path
from dagster_dbt import DbtCliResource, dbt_assets, DagsterDbtTranslator
from dagster import AssetExecutionContext, AutomationCondition

# configure dbt project resource
dbt_project_dir = Path(__file__).joinpath("..", "..", "..", "dbt", "warehouse").resolve()
dbt_warehouse_resource = DbtCliResource(project_dir=os.fspath(dbt_project_dir), global_args=["deps"])

# generate manifest
dbt_manifest_path = (
    dbt_warehouse_resource.cli(
        ["--quiet", "parse"],
        target_path=Path("target"),
    )
    .wait()
    .target_path.joinpath("manifest.json")
)

class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    def get_automation_condition(self, dbt_resource_props): 
        return AutomationCondition.eager()

# load manifest to produce asset defintion
@dbt_assets(manifest=dbt_manifest_path, dagster_dbt_translator=CustomDagsterDbtTranslator())
def dbt_warehouse(context: AssetExecutionContext, dbt_warehouse_resource: DbtCliResource):
    yield from dbt_warehouse_resource.cli(["run"], context=context).stream()