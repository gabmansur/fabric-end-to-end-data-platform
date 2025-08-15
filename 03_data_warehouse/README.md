# 03 — Data Warehouse (Gold / Semantic Layer)

**What & Why**  
Business-ready layer exposed via SQL views. Today these views run on the **Lakehouse SQL endpoint** (Direct Lake). This folder also leaves space to add a dedicated **Fabric Warehouse** later without changing repo structure.

---

## Artifacts
- `lakehouse_sql/VW_Weather_Readings.sql` – one row per API call
- `lakehouse_sql/VW_Weather_Hourly.sql` – hourly aggregates
- `lakehouse_sql/VW_Weather_Daily.sql` – daily aggregates (optional)

---

## How to Deploy (Lakehouse SQL)
1. Open the Lakehouse **SQL analytics endpoint** for `LH_Weather`.
2. Run the view scripts from `lakehouse_sql/*.sql` (**each in its own batch**).
3. Validate:
   ```sql
   SELECT TOP 10 * FROM dbo.VW_Weather_Readings ORDER BY ts_utc DESC;
   SELECT TOP 10 * FROM dbo.VW_Weather_Hourly   ORDER BY hour_start_utc DESC;
   ```

---

## (Optional) Future: Fabric Warehouse

**Why add a Warehouse later?**  
To separate the serving/semantic layer, get SQL features (procedures, indexing roadmap), finer RBAC, and plug Power BI to a stable endpoint while keeping Lakehouse as your data lake.

### Two ways to wire it

#### 1) Recommended: **Shortcuts** to Lakehouse Silver (no data copy)
Keep `dbo.silver_weather` in the Lakehouse as your truth; expose it in a Warehouse via a shortcut.

**Steps (UI)**
1. Create a Warehouse (e.g., **`WH_Weather`**).
2. In the Warehouse ➜ **New shortcut** ➜ **OneLake** ➜ pick your **Lakehouse `LH_Weather`**.  
3. Select the Delta table **`dbo.silver_weather`** ➜ name the shortcut **`dbo.silver_weather_sc`**.
4. Create **views** in the Warehouse that read from `dbo.silver_weather_sc`:

```sql
-- Per-reading view
CREATE OR ALTER VIEW dbo.VW_Weather_Readings AS
SELECT
  file_name,
  run_date,
  name        AS city_name,
  [timestamp] AS ts_utc,
  temp, feels_like, humidity, pressure,
  wind_speed, clouds_all,
  weather_main, weather_description
FROM dbo.silver_weather_sc;

-- Hourly view (UTC)
CREATE OR ALTER VIEW dbo.VW_Weather_Hourly AS
SELECT
  name AS city_name,
  DATEADD(hour, DATEDIFF(hour, 0, [timestamp]), 0) AS hour_start_utc,
  COUNT(*)           AS n_obs,
  AVG(temp)          AS avg_temp_c,
  MIN(temp)          AS min_temp_c,
  MAX(temp)          AS max_temp_c,
  AVG(feels_like)    AS avg_feels_like_c,
  AVG(humidity)      AS avg_humidity,
  AVG(pressure)      AS avg_pressure,
  AVG(wind_speed)    AS avg_wind_speed,
  AVG(clouds_all)    AS avg_clouds
FROM dbo.silver_weather_sc
GROUP BY
  name,
  DATEADD(hour, DATEDIFF(hour, 0, [timestamp]), 0);
```

### Pros & Cons — Shortcuts to Lakehouse Silver

**Pros**
- **Zero duplication**: no extra storage; Warehouse reads the Lakehouse table directly.
- **Always current**: views reflect Silver immediately after the dataflow refresh.
- **Simple ops**: orchestration stays the same (pipeline + dataflow only).
- **Cost-friendly**: no copy jobs, no extra compute to load/refresh Warehouse tables.
- **Fast to ship**: create shortcut + views; no schema copy or backfills required.
- **Lineage preserved**: debugging stays easier because Silver remains the single source of truth.

**Cons**
- **Dependent on Lakehouse availability/perf**: Warehouse queries rely on the Lakehouse behind the shortcut.
- **Feature gaps**: some Warehouse-native features (e.g., certain indexing/maintenance patterns) may not apply to shortcuts.
- **Governance nuance**: fine-grained Warehouse storage policies don’t apply when data isn’t materialized there.
- **Performance edge cases**: very heavy workloads may prefer materializing into Warehouse for isolation.

---

## 2) Optional: Materialize into the Warehouse (copy data)

Load curated Silver into native Warehouse tables (for isolation or performance testing).

### Options
- **CTAS** (Create Table As Select) if cross-database is available in your tenant, or
- **COPY INTO** from OneLake path of the Lakehouse Delta (when appropriate), or
- **Data Factory** pipeline activity **Lakehouse → Warehouse**.

### Example pattern (rebuild table nightly)

```sql
-- One-time: create an empty table with your schema (or use CTAS if supported)
DROP TABLE IF EXISTS dbo.silver_weather_w;
CREATE TABLE dbo.silver_weather_w (
  file_name NVARCHAR(200),
  run_date  DATE,
  name NVARCHAR(120),
  country NVARCHAR(10),
  lat FLOAT, lon FLOAT,
  [timestamp] DATETIME2(3), [date] DATE,
  temp FLOAT, feels_like FLOAT, temp_min FLOAT, temp_max FLOAT,
  pressure INT, humidity INT,
  wind_speed FLOAT, wind_deg INT,
  clouds_all INT, visibility INT,
  weather_main NVARCHAR(80), weather_description NVARCHAR(200)
);

-- Load/refresh from Lakehouse (use your preferred movement method)
-- (If CTAS/CROSS-DB SELECT is enabled, you can do:)
-- INSERT INTO dbo.silver_weather_w
-- SELECT *
-- FROM   [LH_Weather].dbo.silver_weather;  -- adjust to your environment
```

#### Gold views on the Warehouse table

```sql
CREATE OR ALTER VIEW dbo.VW_Weather_Readings AS
SELECT
  file_name, run_date, name AS city_name, [timestamp] AS ts_utc,
  temp, feels_like, humidity, pressure, wind_speed, clouds_all, weather_main, weather_description
FROM dbo.silver_weather_w;

CREATE OR ALTER VIEW dbo.VW_Weather_Hourly AS
SELECT
  name AS city_name,
  DATEADD(hour, DATEDIFF(hour, 0, [timestamp]), 0) AS hour_start_utc,
  COUNT(*) n_obs,
  AVG(temp) avg_temp_c,
  MIN(temp) min_temp_c,
  MAX(temp) max_temp_c,
  AVG(feels_like) avg_feels_like_c,
  AVG(humidity) avg_humidity,
  AVG(pressure) avg_pressure,
  AVG(wind_speed) avg_wind_speed,
  AVG(clouds_all) avg_clouds
FROM dbo.silver_weather_w
GROUP BY name, DATEADD(hour, DATEDIFF(hour, 0, [timestamp]), 0);
```

---

## Power BI hookup

**Goal:** expose your Gold views to Power BI using **Direct Lake** for low-latency analytics.

### Option A — Lakehouse SQL endpoint (current setup)
1. Open **Power BI Desktop** → **Get data** → **Power Platform** → **Power BI datasets** (or **Fabric / OneLake data hub**).
2. Select your workspace → **Lakehouse** (`LH_Weather`) → **SQL endpoint**.
3. Choose the views (e.g., `dbo.VW_Weather_Readings`, `dbo.VW_Weather_Hourly`).
4. Confirm connection mode is **Direct Lake**.  
   - If Desktop shows **DirectQuery/Import**, back out and pick the **SQL endpoint** from the **OneLake data hub** picker.
5. Build visuals, then **Publish** to the same workspace.

### Option B — Fabric Warehouse (shortcut or materialized)
1. In Desktop → **Get data** → **Fabric** (or **OneLake data hub**) → pick **Warehouse** (`WH_Weather`).
2. Select views (same names recommended: `VW_Weather_Readings`, `VW_Weather_Hourly`).
3. Model runs in **Direct Lake** by default for Fabric Warehouse.

### Quick visual starter
- **Slicer**: `city_name`
- **Line chart**: `hour_start_utc` (X) vs `avg_temp_c` (Y) from `VW_Weather_Hourly`
- **Card** (latest reading):
  ```DAX
  Latest Temp (°C) =
  VAR tMax = MAX ( VW_Weather_Readings[ts_utc] )
  RETURN
    CALCULATE ( MAX ( VW_Weather_Readings[temp] ), VW_Weather_Readings[ts_utc] = tMax )
  ```
- **Card**: “Last Observation (UTC)”  
  ```DAX
  Last Observation (UTC) =
  MAX ( VW_Weather_Readings[ts_utc] )
  ```

### Refresh & latency
- **Direct Lake** models don’t require scheduled dataset refresh; freshness follows your **pipeline + dataflow** cadence.
- If you use **materialized Warehouse tables**, schedule their load **after** the Silver dataflow completes.

### Security (optional)
- Keep views in `dbo` but grant **SELECT** only to a business/reader role.
- Implement RLS in the **semantic model** (preferred) or via **row-filtered views** (e.g., filter by `city_name`).

### Gotchas
- Direct Lake supports tabular-friendly types only — avoid Binary/Record/List columns in views.
- `CREATE VIEW` must exist before Desktop connects; re-open the connection if you add new views.
- Time zone: views use **UTC**; convert in DAX or expose a local-time view if required.