# How to Use — Silver Dataflow (DFG_Weather_BRZToSIL)

Turn Bronze JSON files into a typed Silver table (`dbo.silver_weather`) using Power Query (Dataflows Gen2).


## Prereqs
- Lakehouse (e.g., `LH_Weather`) with Bronze files landing at:
  `Files/bronze/raw/weather/city=amsterdam/run_date=YYYY-MM-DD/weather_*.json`
- These two M scripts in this folder:
  - `silver_weather_sample.m`  (function to parse one file)
  - `silver_weather_combined.m` (combines + parses all files)
- Your **workspaceId** and **lakehouseId** (you can copy them from any auto-generated M after browsing to the Lakehouse once).


## Quick start (5 steps)

1) **Create the dataflow**
   - New ➜ **Dataflow Gen2** ➜ name: `DFG_Weather_BRZToSIL`.

2) **Add the parser function**
   - Add **Blank query** ➜ rename to **`fnParseOpenWeatherCurrent`**.
   - Open **Advanced Editor** ➜ paste contents of **`silver_weather_sample.m`** ➜ **Save**.

3) **Add the combined query**
   - Add **Blank query** ➜ rename to **`silver_weather`**.
   - **Advanced Editor** ➜ paste **`silver_weather_combined.m`**.
   - Replace `"<REPLACE_WORKSPACE_ID>"` and `"<REPLACE_LAKEHOUSE_ID>"` with yours.
   - If your city folder differs, edit the `city=amsterdam` line.

4) **Output to the Lakehouse**
   - Select the **`silver_weather`** query ➜ **Destination/Output**:  
     - Lakehouse: your lakehouse (e.g., `LH_Weather`)  
     - **Table:** `dbo.silver_weather`  
     - **Load setting:** **Append**  
   - On mapping, click **Reset/Auto-map** and keep only these columns:  
     `file_name, run_date, name, country, lat, lon, timestamp, date, temp, feels_like, temp_min, temp_max, pressure, humidity, wind_speed, wind_deg, clouds_all, visibility, weather_main, weather_description`
   - **Save** ➜ **Refresh now**.

5) **Verify**
   - In the Lakehouse **SQL endpoint**:
     ```sql
     SELECT COUNT(*) AS total_rows FROM dbo.silver_weather;

     SELECT TOP 10 *
     FROM dbo.silver_weather
     ORDER BY [timestamp] DESC;
     ```


## Orchestration (pick one)
- **Pipeline-driven (recommended):** In your ingest pipeline, add a **Run Dataflow** activity after the Copy (success path), **Wait for completion = On**. Then you only schedule the pipeline.
- **Separate schedules:** Schedule the pipeline hourly; schedule the dataflow **+2–5 minutes** after the pipeline.



## Customize (optional)

### Change city
- In `silver_weather_combined.m`, update the line:
  ```m
  CityFolder = Weather{[Name = "city=amsterdam"]}[Content],
  ```
  to your desired folder (e.g., `city=paris`).

### Multi-city
- Land Bronze into multiple `city=<name>` folders via a **ForEach** in the pipeline.
- In Dataflow, instead of selecting a single `city=...`, expand the **`Weather`** folder’s **Content** twice (cities ➜ files) before parsing so all cities are included. Keep the `name` field from the JSON as the city label.


## Troubleshooting

- **`run_date` is null:** Extract from a decoded path:
  ```m
  Uri.UnescapeDataString([#"Folder Path.1"]) 
  // then Text.BetweenDelimiters(..., "run_date=", "/")
  ```
- **Mapping shows `Attributes`/`Folder Path`:** Remove them (not needed in Silver).
- **`timestamp` is null or errors:** Ensure the **sample** query computes `timestamp` from `dt` *before* dropping `dt`:
  ```m
  #datetime(1970,1,1,0,0,0) + #duration(0,0,0,[dt])
  ```
- **Function not found:** The parser query must be named **`fnParseOpenWeatherCurrent`** (or update the call in the combined query).
- **Combine Files button missing (if building via UI):** You must have a column **named `Content` with Binary** values selected; expand subfolders until files are listed.



## What this creates
- Lakehouse table: **`dbo.silver_weather`** (append-only, typed, with lineage `file_name` + partition `run_date`)
- Ready for Gold views in `03_data_warehouse` (Hourly, Daily, Latest)
