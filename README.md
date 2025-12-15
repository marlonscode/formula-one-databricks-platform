# formula-one-databricks-platform 🏎️💨

- Fact tables
    - Race result: One row per driver per race
    - Qualifying result: One row per driver per qualifying session

## Table of Contents
- [Introduction](#introduction)
- [Solution Architecture](#solution-architecture)
- [Techniques used](#techniques-used)
- [Project Components](#project-components)
    - [Generation](#generation)
    - [Ingestion](#ingestion)
    - [Storage](#storage)
    - [Transformation](#transformation)
    - [Serving](#serving)
- [Screenshots](#screenshots)


## Introduction
This is an end-to-end Databricks data platform, covering the entire data engineering lifecycle: generation, ingestion, storage, transformation and serving (including a dashboard). The project uses data that represents a bike manufacturer & retailer. The data reflects standard business operations, so its structures and concepts are broadly applicable to almost any industry.

Various data modelling techniques were used in order to answer the following business questions:

History dashboard
1. Winning driver/constructor by season (table)
2. Drivers with most race wins of all time (horizontal bar)
2. Constructors with most race wins of all time (horizontal bar)
5. Constructors standings by year (line/shaded line)
6. Countries which produce the most F1 drivers
10. Circuit location concentration (map)

IoT dashboard
1. Air temp
2. Track temp
3. Humidity
4. Air pressure


## Solution Architecture

<img src="images/architecture.png" alt="Description" width="700" />
Figure 1: Solution architecture

## Techniques used

ELT/ETL
- 
Python
- 
SQL/dbt
- 
Cloud (AWS, IaC)
- 
Data warehousing (Snowflake/Databricks)
- 
Data modelling
-
Orchestration
- 
Serving (semantic layer, dashboard)
- 
CI/CD
- 
Spark
- 
Streaming
- 

Examples
- Cloud deployment in AWS (ECS, EC2, IAM, RDS, S3 etc)
- Data Ingestion service (Airbyte)
- Incremental Extract using Change Data Capture (CDC)
- Various data transformations (window functions, joins, calculations etc)
- `dbt` used for data modelling/transformation
- Kimball/Dimensional modelling (Star Schema)
- One Big Table for BI Consumption
- Data quality tests
- Semantic modelling (metrics, calculated columns)
- Data visualisation (Preset dashboard)

## Project Components

Generation 
- There was a single data source for this project: The DVD Rental dataset, hosted in nn Amazon RDS PostgreSQL instance. 
- This dataset contained 15 tables, modelled in 3NF.
- The dataset represented the various entities of a typical store e.g. `customer`, `order`, `address` etc
Ingestion 
- Airbyte was the data integration tool used in this project, being hosted on an Amazon EC2 instance
- The data source was RDS, and the destination was databricks
- The Extract/Load pattern used was incremental CDC (Change Data Capture)
Storage 
- databricks was used as the data warehouse in this project
- Airbyte inserted data into databricks with CDC timestamp columns
Transformation 
- `dbt` was used to transform data within databricks
- `dbt` was hosted on ECS platform, and set to run daily using a Scheduled Task
- Medallion Architecture (Raw, Staging, Marts) was used for data layers
- Within marts layer, `dbt` was used to transform the data from 3NF into Star Schema (Kimball/Dimensional modelling)
- To aid reporting, an OBT model was also created in the marts layer
Serving
- A Preset Dashboard was created to answer the business questions above
- Please see `screenshots` section of this `README` to see the dashboard

## Screenshots

<img src="images/dashboard.png" alt="Description" width="700" />
Figure 2: Preset dashboard for DVD dataset

<img src="images/dag.png" alt="Description" width="700" />
Figure 3: `dbt` DAG for data warehouse

<img src="images/erd.png" alt="Description" width="700" />
Figure 4: Kimball model for DVD dataset
