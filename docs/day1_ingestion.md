# Day 1 – Ingestion Layer

**Goal:** Set up and test ingestion from multiple sources (batch + streaming) into Microsoft Fabric.  
This maps to **DP-700: Ingest and Transform Data** skills.

## Folder Structure
```
01_ingestion/
│
├── pipelines/                # JSON exports of Data Factory pipelines
├── dataflows/                # Dataflows Gen2 exports
├── scripts/                  # Python, SQL, or helper scripts
├── datasets/                 # Sample data used for ingestion
└── docs/                     # Notes, setup instructions, gotchas
```

## Step-by-Step Plan

### 1. Batch Ingestion – Azure Blob Storage
- **Data:** NYC Taxi Yellow Trip Data (CSV or Parquet)  
- **Fabric Tool:** Data Factory (Copy Data activity)  
- **Bronze Layer Target:** Lakehouse table `bronze_nyc_taxi`  
- **Tasks:**
  1. Upload raw files to an Azure Blob Storage container.  
  2. In Data Factory, create a new Pipeline:
     - Source: Azure Blob Storage  
     - Sink: Fabric Lakehouse  
     - Mapping: Auto (no transformations yet)  
  3. Trigger pipeline and validate data in Lakehouse.  
  4. Export pipeline JSON to `pipelines/` folder.

### 2. Batch Ingestion – Public API
- **Data:** OpenWeather API (sample city weather)  
- **Fabric Tool:** Dataflow Gen2 (or notebook for more control)  
- **Bronze Layer Target:** Lakehouse table `bronze_weather`  
- **Tasks:**
  1. Sign up for OpenWeather free API key.  
  2. Create Dataflow:
     - Source: API endpoint (e.g., `api.openweathermap.org/data/2.5/weather?q=London&appid=API_KEY`)  
     - Transform: Select only useful columns (`temp`, `humidity`, `timestamp`, `city`)  
     - Sink: Fabric Lakehouse  
  3. Schedule refresh (e.g., hourly).  
  4. Export Dataflow JSON to `dataflows/` folder.

### 3. Streaming Ingestion – IoT Simulation
- **Data:** Simulated device sending JSON events (`deviceId`, `temp`, `humidity`, `timestamp`)  
- **Fabric Tool:** Eventstream → KQL Database  
- **Tasks:**
  1. Create Eventstream in Fabric.  
  2. Use a Python script in `scripts/` to push simulated data to Event Hub (or directly to Eventstream endpoint).  
  3. Route Eventstream output to KQL table `iot_sensors_stream`.  
  4. Verify near real-time ingestion in Real-Time Analytics explorer.

## Deliverables for Day 1
1. Pipelines JSON – `pipelines/nyc_taxi_pipeline.json`  
2. Dataflow JSON – `dataflows/weather_dataflow.json`  
3. IoT Simulator Script – `scripts/simulate_iot.py`  
4. Day 1 Documentation – `docs/day1_ingestion.md`:
   - Data sources  
   - Connection details (scrub secrets)  
   - Decisions made (e.g., why Blob Storage instead of OneLake direct upload)  
   - Gotchas / issues  