# Fabric End-to-End Data Platform
*An enterprise-style Microsoft Fabric project demonstrating ingestion, transformation, analytics, and governance — built from the ground up.*

## **Overview**
This project showcases the design and implementation of a modern, end-to-end data platform using Microsoft Fabric.  
It follows industry best practices for data engineering and analytics, covering the complete journey from raw data ingestion to secure, real-time, business-ready insights.  

The solution was built as part of my preparation for the **Microsoft Certified: Fabric Data Engineer Associate (DP-700)** exam, and serves as both a learning reference and portfolio project.

## **Learning Goals**
- Master the **end-to-end Fabric data workflow** from ingestion to governance.
- Prepare for the **DP-700: Fabric Data Engineer Associate** certification.
- Build a **portfolio-ready project** showcasing enterprise-grade patterns.
- Practice **PySpark, SQL, KQL, and DAX** in real-world-style scenarios.

## **Architecture**
The platform is designed using the medallion architecture (Bronze → Silver → Gold) within Fabric’s Lakehouse and Warehouse environments.

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

## **Key Features (Mapped to DP-700 Skills Measured)**

- **Multi-source ingestion** *(Ingest and Transform Data)*  
  - Batch ingestion*from Azure Blob Storage (NYC Taxi dataset) and a public API (OpenWeather sample).  
  - Streaming ingestion using Eventstreams connected to a simulated IoT feed, stored in a KQL Database for near real-time analytics.  

- **Delta Lake storage** (Ingest and Transform Data)
  - Implemented schema evolution to handle changes in incoming data without breaking pipelines.  
  - Applied partitioning strategies (e.g., by date) to optimize query performance and reduce storage costs.  

- **Data transformation** *(Ingest and Transform Data)*  
  - PySpark notebooks for complex cleaning, joining, and aggregation logic, including deduplication and null handling.  
  - SQL queries for lightweight transformations, creating views, and preparing gold-layer datasets for reporting.  

- **Warehouse integration** *(Implement and Manage an Analytics Solution)*  
  - Loaded curated silver data into a Fabric Warehouse and connected it directly to Power BI using DirectLake mode for minimal latency.  
  - Built semantic models with business-friendly naming conventions and calculated columns/measures.  

- **Power BI reporting** *(Implement and Manage an Analytics Solution)*  
  - Designed interactive dashboards for trip volume, revenue trends, and weather correlation analysis.  
  - Added measures and calculated columns in DAX to provide KPIs like average fare per trip and peak usage hours.  

- **Security & governance** *(Implement and Manage an Analytics Solution)*  
  - Configured **RBAC roles for workspace-level and item-level permissions (Admin, Engineer, Analyst).  
  - Implemented Row-Level Security (RLS)** on semantic models to restrict data visibility by region.  
  - Applied sensitivity labels to sensitive columns (e.g., customer information) and endorsed certified datasets for trusted use.  

- **Monitoring & optimization** *(Monitor and Optimize an Analytics Solution)*  
  - Set up pipeline monitoring with alerts for failed runs and refresh failures.  
  - Applied performance tuning to Spark queries (caching, partition pruning) and optimized dataset storage layouts.  



## **DP-700 Skills Coverage Table**

| **Exam Domain** | **Repo Folders** | **What’s Inside** |
|-----------------|------------------|-------------------|
| **1. Implement and Manage an Analytics Solution** (30–35%) | [`01_ingestion/`](./01_ingestion) <br> [`03_data_warehouse/`](./03_data_warehouse) <br> [`05_security_governance/`](./05_security_governance) | Workspace setup, orchestration, semantic models, DirectLake, RBAC, RLS, sensitivity labels |
| **2. Ingest and Transform Data** (30–35%) | [`01_ingestion/`](./01_ingestion) <br> [`02_lakehouse_transforms/`](./02_lakehouse_transforms) <br> [`04_real_time_analytics/`](./04_real_time_analytics) | Batch ingestion (Blob/API), streaming ingestion (Eventstreams/KQL), PySpark & SQL transformations, Delta Lake |
| **3. Monitor and Optimize an Analytics Solution** (30–35%) | [`06_monitoring_optimization/`](./06_monitoring_optimization) | Monitoring pipelines & datasets, alerts, Spark performance tuning, cost optimization |


## **Repo Structure → DP-700 Skills Mapping (Visual)**

```text
                 ┌─────────────────────────────────────────┐
                 │       DP-700: Fabric Data Engineer       │
                 │     Skills Coverage in this Project      │
                 └─────────────────────────────────────────┘

[ Implement & Manage Analytics Solution (30–35%) ]
 ├── 01_ingestion/           → Pipelines, Dataflows, orchestration
 ├── 03_data_warehouse/      → Semantic models, DirectLake, Power BI
 └── 05_security_governance/ → RBAC, RLS, sensitivity labels, governance

[ Ingest & Transform Data (30–35%) ]
 ├── 01_ingestion/           → Batch ingestion from Blob & APIs
 ├── 02_lakehouse_transforms/→ PySpark transformations, Delta Lake, partitioning
 └── 04_real_time_analytics/ → Streaming ingestion, Eventstreams, KQL queries

[ Monitor & Optimize Analytics Solution (30–35%) ]
 └── 06_monitoring_optimization/ → Monitoring, alerts, performance tuning, cost control
```


## **Technology Stack**
- **Microsoft Fabric**
  - Data Factory
  - Lakehouse
  - Dataflows Gen2
  - Warehouses
  - Eventstreams
  - Real-Time Analytics (KQL)
  - Power BI (DirectLake)
- **Languages & Querying**
  - PySpark
  - SQL
  - KQL
  - DAX
- **Other Tools**
  - Azure Blob Storage (data source)
  - Git & GitHub for version control


## **Folder Structure**
```plaintext
fabric-end-to-end-data-platform/
│
├── 01_ingestion/                # Pipelines & Dataflows JSON exports
├── 02_lakehouse_transforms/     # PySpark notebooks & SQL scripts
├── 03_data_warehouse/           # T-SQL scripts, semantic model exports
├── 04_real_time_analytics/      # KQL scripts & streaming setup
├── 05_security_governance/      # RBAC config, RLS, sensitivity label docs
├── 06_monitoring_optimization/  # Monitoring & performance tuning notes
└── README.md
```


## **How to Use This Repo**

1. **Set up Microsoft Fabric**  
   - If you don’t have access, sign up for a Fabric trial through your Microsoft 365 admin center.

2. **Clone this repository**
   ```bash
   git clone https://github.com/your-username/fabric-end-to-end-data-platform.git
   ```

3. **Navigate to the module you want to explore**
   - Example:  
     - `01_ingestion/` → Pipelines  
     - `02_lakehouse_transforms/` → PySpark transformations  

4. **Import artifacts into your Fabric workspace**
   - Pipelines and Dataflows → Data Factory  
   - Notebooks → Data Engineering environment  
   - SQL scripts → Lakehouse or Warehouse 
   - KQL scripts → Real-Time Analytics

5. **Follow the build sequence**
   1. Ingestion  
   2. Lakehouse transformations  
   3. Warehouse  
   4. Security & Governance  
   5. Real-Time Analytics  
   6. Monitoring & Optimization

6. **Use the `docs/` folder inside each module**
   - Contains setup instructions, design decisions, and “gotchas” discovered during implementation.


## **Study & Build Log**

| Day | Module | Focus | Key Skills Practiced |
|-----|--------|-------|----------------------|
| **Day 1** | 01_ingestion | Set up Fabric workspace, ingest batch data from Azure Blob Storage (NYC Taxi dataset), ingest API data (OpenWeather) | Data Factory pipelines, Dataflows Gen2, linked services, parameterization |
| **Day 2** | 02_lakehouse_transforms | Transform raw data to Silver layer using PySpark and SQL | PySpark data cleaning, joins, aggregations, Delta Lake schema evolution, partitioning |
| **Day 3** | 03_data_warehouse | Load curated data into Warehouse, connect to Power BI | T-SQL scripts, semantic model creation, DirectLake, business-friendly naming |
| **Day 4** | 05_security_governance | Apply RBAC, RLS, and sensitivity labels | Row-Level Security (RLS), workspace roles, dataset certification |
| **Day 5** | 04_real_time_analytics | Ingest and analyze streaming data from Eventstreams | KQL database creation, streaming table setup, KQL queries |
| **Day 6** | 06_monitoring_optimization | Set up monitoring, alerts, and performance tuning | Pipeline run history, alert rules, Spark caching, cost optimization |