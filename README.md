# Fabric End-to-End Data Platform
*An enterprise-style Microsoft Fabric project demonstrating ingestion, transformation, analytics, and governance — built from the ground up.*

## Overview
This project showcases the design and implementation of a modern, end-to-end data platform using [Microsoft Fabric](https://learn.microsoft.com/en-us/fabric/).  
It follows industry best practices for data engineering and analytics, covering the complete journey from raw data ingestion to secure, real-time, business-ready insights.  

The solution was built as part of my preparation for the **[Microsoft Certified: Fabric Data Engineer Associate (DP-700)](https://learn.microsoft.com/en-us/credentials/certifications/fabric-data-engineer-associate/)** exam, and serves as both a learning reference and portfolio project.

## Learning Goals
- Master the end-to-end Fabric data workflow from ingestion to governance.
- Prepare for the DP-700: Fabric Data Engineer Associate certification.
- Build a portfolio-ready project showcasing enterprise-grade patterns.
- Practice **[PySpark](https://spark.apache.org/docs/latest/api/python/)**, **[SQL](https://learn.microsoft.com/en-us/sql/sql-server/)**, **[KQL](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)**, and **[DAX](https://learn.microsoft.com/en-us/dax/)** in real-world-style scenarios.

## Architecture
The platform is designed using the **medallion architecture** (Bronze → Silver → Gold) within Fabric’s Lakehouse and Warehouse environments.

```text
            ┌─────────────────────────┐
            │  Data Sources (API, CSV, │
            │  Event Streams)          │
            └───────────────┬──────────┘
                            │
                ┌───────────▼────────────┐
                │ Ingestion Layer         │
                │ (Pipelines, Dataflows)  │
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │ Lakehouse (Bronze)      │
                │ Raw data storage        │
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │ Transformation Layer    │
                │ PySpark / SQL (Silver)  │
                └───────────┬────────────┘
                            │
                ┌───────────▼────────────┐
                │ Warehouse (Gold)        │
                │ Semantic Models / Power │
                │ BI Dashboards           │
                └─────────────────────────┘
``` 

## Key Features (Mapped to DP-700 Skills Measured)

- **Multi-source ingestion** *(Ingest and Transform Data)*  
  - **Batch ingestion** from [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/) and a public API ([OpenWeather](https://openweathermap.org/api) sample).  
  - **Streaming ingestion** using [Eventstreams](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/event-streams/overview) connected to a simulated IoT feed, stored in a [KQL Database](https://learn.microsoft.com/en-us/azure/data-explorer/) for near real-time analytics.  

- **[Delta Lake](https://delta.io/)** storage *(Ingest and Transform Data)*  
  - Implemented **schema evolution** to handle changes in incoming data without breaking pipelines.  
  - Applied **partitioning strategies** (e.g., by date) to optimize query performance and reduce storage costs.  

- **Data transformation** *(Ingest and Transform Data)*  
  - **[PySpark notebooks](https://spark.apache.org/docs/latest/api/python/)** for complex cleaning, joining, and aggregation logic, including deduplication and null handling.  
  - **[SQL queries](https://learn.microsoft.com/en-us/sql/sql-server/)** for lightweight transformations, creating views, and preparing gold-layer datasets for reporting.  

- **Warehouse integration** *(Implement and Manage an Analytics Solution)*  
  - Loaded curated silver data into a Fabric **[Warehouse](https://learn.microsoft.com/en-us/fabric/data-warehouse/)** and connected it directly to [Power BI](https://learn.microsoft.com/en-us/power-bi/) using DirectLake mode for minimal latency.  
  - Built semantic models with business-friendly naming conventions and calculated columns/measures.  

- **[Power BI](https://learn.microsoft.com/en-us/power-bi/) reporting** *(Implement and Manage an Analytics Solution)*  
  - Designed interactive dashboards for trip volume, revenue trends, and weather correlation analysis.  
  - Added **[DAX](https://learn.microsoft.com/en-us/dax/)** measures and calculated columns to provide KPIs like average fare per trip and peak usage hours.  

- **Security & governance** *(Implement and Manage an Analytics Solution)*  
  - Configured **[RBAC roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/)** for workspace-level and item-level permissions.  
  - Implemented **Row-Level Security (RLS)** on semantic models to restrict data visibility by region.  
  - Applied **[sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels)** to sensitive columns and endorsed certified datasets for trusted use.  

- **Monitoring & optimization** *(Monitor and Optimize an Analytics Solution)*  
  - Set up pipeline monitoring with alerts for failed runs and refresh failures.  
  - Applied performance tuning to Spark queries (caching, partition pruning) and optimized dataset storage layouts.  


## Technology Stack
- **[Microsoft Fabric](https://learn.microsoft.com/en-us/fabric/)**  
  - [Data Factory](https://learn.microsoft.com/en-us/fabric/data-factory/)  
  - [Lakehouse](https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-overview)  
  - [Dataflows Gen2](https://learn.microsoft.com/en-us/power-query/dataflows/dataflows-introduction)  
  - [Warehouses](https://learn.microsoft.com/en-us/fabric/data-warehouse/)  
  - [Eventstreams](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/event-streams/overview)  
  - [Real-Time Analytics (KQL)](https://learn.microsoft.com/en-us/azure/data-explorer/)  
  - [Power BI (DirectLake)](https://learn.microsoft.com/en-us/fabric/get-started/directlake-overview)  

- **Languages & Querying**  
  - [PySpark](https://spark.apache.org/docs/latest/api/python/)  
  - [SQL](https://learn.microsoft.com/en-us/sql/sql-server/)  
  - [KQL](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)  
  - [DAX](https://learn.microsoft.com/en-us/dax/)  

- **Other Tools**  
  - [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/)  
  - [Git](https://git-scm.com/) & [GitHub](https://github.com/) for version control  


## How to Use This Repo

1. **Set up [Microsoft Fabric](https://learn.microsoft.com/en-us/fabric/)**  
   - If you don’t have access, sign up for a [Fabric trial](https://learn.microsoft.com/en-us/fabric/get-started/fabric-trial) through your Microsoft 365 admin center.

2. **Clone this repository**
   ```bash
   git clone https://github.com/your-username/fabric-end-to-end-data-platform.git
   ```

3. **Navigate to the module you want to explore**  
   - [`01_ingestion`](./01_ingestion) → Pipelines  
   - [`02_lakehouse_transforms`](./02_lakehouse_transforms) → PySpark transformations  
   - [`03_data_warehouse`](./03_data_warehouse) → Warehouse  
   - [`04_real_time_analytics`](./04_real_time_analytics) → KQL scripts and streaming  
   - [`05_security_governance`](./05_security_governance) → Security and governance  
   - [`06_monitoring_optimization`](./06_monitoring_optimization) → Monitoring and optimization  

4. **Import artifacts into your Fabric workspace**  
   - Pipelines and Dataflows → [Data Factory](https://learn.microsoft.com/en-us/fabric/data-factory/)  
   - Notebooks → [Data Engineering](https://learn.microsoft.com/en-us/fabric/data-engineering/) environment  
   - SQL scripts → [Lakehouse](https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-overview) or [Warehouse](https://learn.microsoft.com/en-us/fabric/data-warehouse/)  
   - KQL scripts → [Real-Time Analytics](https://learn.microsoft.com/en-us/fabric/real-time-intelligence/)  

5. **Follow the build sequence**  
   1. Ingestion  
   2. Lakehouse transformations  
   3. Warehouse  
   4. Security & Governance  
   5. Real-Time Analytics  
   6. Monitoring & Optimization  

6. **Use the `docs/` folder inside each module**  
   - Contains setup instructions, design decisions, and “gotchas” discovered during implementation.