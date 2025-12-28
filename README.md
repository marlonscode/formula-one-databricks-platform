# F1 Databricks Platform 🏎️💨

I've been watching a lot of F1 recently, which inspired me to build this end-to-end Databricks platform based on F1 data. This batch/streaming platform covers the entire data engineering lifecycle:

- Generation
- Ingestion
- Storage
- Transformation
- Serving

The business questions we are trying to answer are:

- What are the live weather conditions at each track, using mocked IoT sensor streaming?
- What is the performance of the top 5 teams over the last 50 years?
- Who are the best drivers in history?
- Which driver/team won the last 10 seasons?
- Which countries produce the most drivers?


## End Result

The end result of this platform is the following dashboard which answers the business questions

<img src="images/preset1.png" alt="Description" width="700" />
Figure: Historical F1 analysis

<img src="images/preset2.png" alt="Description" width="700" />
Figure: Real-time IoT readings


## Solution Architecture

The solution was built on AWS, Databricks and various other modern stack tools.

<img src="images/concept_diagram.png" alt="Description" width="700" />
Figure: Simplified architecture

<img src="images/arch_diagram.png" alt="Description" width="700" />
Figure: Detailed architecture


## Features

This project is an end-to-end data engineering platform for batch and streaming data, built with production-grade best practices.

- **ELT & Streaming Pipelines**
  - Airbyte pipelines extract and load data from multiple sources
  - Supports batch and micro-batch streams
  - Extraction patterns: incremental and full
  - Load patterns: upsert, append, overwrite
  - Kafka (Confluent) buffers IoT streaming data
  - All jobs orchestrated with Dagster on a schedule

- **Cloud & Infrastructure**
  - Deployed on AWS using Terraform
  - Services: Lambda, ECS, S3, RDS, SQS, SNS, EventBridge, IAM

- **Data Modeling & Warehousing**
  - Kimball & OBT modeling with medallion architecture (raw → staging → marts)
  - 3 fact tables, 6 dimension tables, 2 OBT tables
  - SCD2 tables track historical changes
  - Partitioning applied to improve query performance
  - Delta tables provide ACID compliance and time travel

- **Analytics Engineering**
  - SQL transformations using dbt
  - Techniques: joins, aggregations, window functions, CTEs
  - dbt features: macros, generic/custom tests, snapshots, profiles/targets, packages, incremental models
  - SparkSQL executes dbt pipelines on Databricks clusters

- **Python & Orchestration**
  - 6 Lambda functions written in Python
  - Uses type hints, decorators, and object-oriented patterns
  - Unit testing with pytest and linting in CI/CD
  - Orchestration handled via Dagster

- **CI/CD & Git**
  - GitHub Actions for linting, testing, Docker container builds, and deployments
  - Branch protection rules and PR-based workflows enforce code quality

- **Dashboarding & Semantic Layer**
  - Preset dashboards for visualization
  - Semantic layer techniques: calculated metrics and columns

- **Additional Engineering Practices**
  - Python virtual environments for dependency management
  - Python linting enforced
  - CI/CD ensures branch deployments and automated testing



## Screenshots

<img src="images/dbt.png" alt="Description" width="700" />
Figure: dbt DAG

<img src="images/erds.png" alt="Description" width="700" />
Figure: Kimball models created using dbt

<img src="images/airbyte.png" alt="Description" width="700" />
Figure: Airbye connections

<img src="images/db.png" alt="Description" width="700" />
Figure: Databricks compute cluster monitoring

<img src="images/dagster.png" alt="Description" width="700" />
Figure: Dagster pipeline successful run

<img src="images/kafka.png" alt="Description" width="700" />
Figure: Confluent Kafka S3 connector

<img src="images/gha.png" alt="Description" width="700" />
Figure: Github Actions workflow runs

<img src="images/cicd.png" alt="Description" width="700" />
Figure: CI/CD flow diagram


