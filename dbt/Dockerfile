FROM python:3.10-slim

RUN pip install --no-cache-dir dbt-core dbt-databricks

COPY . .

ENTRYPOINT ["/bin/bash", "build_dbt.sh"]




