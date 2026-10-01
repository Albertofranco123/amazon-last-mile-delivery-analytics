# AWS Amazon Last-Mile Analytics

**End-to-end AWS data analytics project transforming Amazon last-mile delivery data into operational insights using Amazon S3, AWS Glue, Amazon Athena, SQL, and Amazon QuickSight.**

## Project Overview

This project demonstrates the end-to-end development of a cloud-based data analytics pipeline using AWS, SQL, and business analytics.

Using the Amazon Last-Mile Routing Research Challenge dataset from AWS Open Data, the project transforms nested JSON delivery data into structured, analytics-ready datasets for evaluating route quality, delivery success, and vehicle capacity utilization.

The solution integrates Amazon S3, AWS Glue ETL, AWS Glue Crawler and Data Catalog, Amazon Athena, and Amazon QuickSight to create a complete workflow from raw data ingestion and transformation to SQL analysis and dashboard visualization.

The project analyzes more than **1.45 million packages**, **904,000 stops**, and **6,112 delivery routes**.

## Business Objectives

The goal of this project is to understand which operational factors are associated with last-mile delivery performance.

The analysis focuses on three business questions:

### Route Quality
**What operational characteristics differentiate High-, Medium-, and Low-quality routes?**

### Delivery Success
**Where and under what operational conditions are unsuccessful deliveries more likely to occur?**

### Vehicle Workload & Capacity
**How is estimated vehicle capacity utilization distributed across delivery routes?**

## AWS Data Pipeline

<!-- AWS pipeline architecture image will be added here. -->

The project follows a **raw → transform → catalog → analyze → visualize** architecture.

| Stage | AWS Service | Purpose |
| --- | --- | --- |
| Data Source | AWS Open Data | Provides the Amazon Last-Mile Routing Research Challenge dataset. |
| Raw Storage | Amazon S3 | Stores the original nested JSON route and package data. |
| Transformation | AWS Glue ETL | Parses, flattens, and transforms nested JSON into structured analytical datasets. |
| Processed Storage | Amazon S3 | Stores analytics-ready routes, stops, and packages datasets in Parquet format. |
| Cataloging | AWS Glue Crawler & Data Catalog | Discovers the processed schemas and registers tables for querying. |
| Analysis | Amazon Athena | Performs SQL-based data quality checks, exploratory analysis, and business analytics. |
| Visualization | Amazon QuickSight | Presents KPIs, visualizations, and operational insights in an interactive dashboard. |

### Pipeline Flow

```text
AWS Open Data
      ↓
Amazon S3 — Raw JSON
      ↓
AWS Glue ETL — Parse + Flatten + Transform
      ↓
Amazon S3 — Processed Parquet
      ↓
AWS Glue Crawler
      ↓
AWS Glue Data Catalog — routes | stops | packages
      ↓
Amazon Athena — SQL / EDA / Business Analytics
      ↓
Amazon QuickSight — Dashboard / KPIs / Insights
```

## Data Schema

AWS Glue transformed the nested source data into three primary analytical tables:

- **routes** — one record per delivery route
- **stops** — one record per stop within a route
- **packages** — one record per package within a route and stop

The main relationships are:

```text
routes
  │ route_id
  ▼
stops
  │ route_id + stop_id
  ▼
packages
```

<!-- Data schema image will be added here. -->

## SQL Analysis

Amazon Athena was used to perform data validation, exploratory analysis, and business-focused SQL analysis.

### Data Quality & EDA
The EDA workflow validates dataset grain, uniqueness, NULL values, package dimensions, time-window consistency, route capacity values, and stop coordinates.

- [View Data Quality & EDA SQL](sql/eda/data_quality.sql)

### Business Analytics

The business analysis is organized around the three project objectives:

- [Route Quality Analysis](sql/analytics/route_quality.sql)
- [Delivery Success Analysis](sql/analytics/delivery_success.sql)
- [Vehicle Capacity Analysis](sql/analytics/vehicle_capacity.sql)

## Key Insights

<!-- Key insights summary image will be added here. -->

### Route Quality

High-quality routes averaged approximately **141 stops per route**, compared with **154 for Medium** and **151 for Low** routes.

Package count, zone count, planned service time, package volume, and estimated capacity utilization showed relatively small differences across route-quality groups.

**Insight:** Route workload alone does not appear to explain route quality.

### Delivery Success

The overall non-delivery rate was approximately **0.76%**, but the rate varied substantially across delivery stations.

- **DLA3:** 1.91%
- **DLA8:** 1.57%
- **DCH1:** 1.32%

Station-level differences were larger than the differences observed across route-quality and zone-complexity groups.

**Insight:** Unsuccessful deliveries appear to be more concentrated at specific stations than explained by route score or zone count alone.

### Vehicle Capacity

Estimated vehicle capacity utilization averaged approximately **74.04%**, with a median of approximately **73.90%**.

The middle 50% of routes ranged from approximately **63.06% to 85.59% estimated utilization**, showing meaningful route-level variation around the overall average.

**Insight:** The utilization distribution provides more operational context than the network-wide average alone.

> Capacity utilization is an estimate based on summed package dimensions relative to executor vehicle volumetric capacity. It should not be interpreted as physical loading efficiency or proof of vehicle overloading.

## Amazon QuickSight Dashboard

The final stage of the project uses Amazon QuickSight to translate the SQL analysis into an interactive operational dashboard.

The dashboard is designed to highlight:

- Total Routes
- Total Packages
- Overall Non-Delivery Rate
- Estimated Average Vehicle Capacity Utilization
- Route Quality Distribution
- Non-Delivery Rate by Station
- Vehicle Capacity Utilization Distribution

<!-- QuickSight dashboard image will be added here. -->

## Technologies

### Cloud & Data Engineering
- AWS Open Data
- Amazon S3
- AWS Glue ETL
- AWS Glue Crawler
- AWS Glue Data Catalog
- Apache Parquet

### Data Analytics
- Amazon Athena
- SQL
- Exploratory Data Analysis
- Data Quality Validation
- KPI Analysis

### Business Intelligence
- Amazon QuickSight
- Dashboard Development
- Data Visualization

## Author

**Alberto Franco**

B.S. Business Administration — Information Systems  
Minor in Finance  
San Diego State University

Focused on Data Analytics, Business Intelligence, Business Analysis, and Supply Chain & Operations Analytics.

[GitHub Profile](https://github.com/Albertofranco123)
