# Pipeline: PL_Weather_API_ToBronze

Ingest **OpenWeather current conditions** as **raw JSON (binary)** into the Lakehouse **Files** (Bronze), partitioned by `run_date`.

## Source (HTTP)

- **Connection (recommended)**
  - **Base URL:** `https://api.openweathermap.org`
  - **Authentication:** Anonymous

- **Request**
  - **Relative URL:**  
    `/data/2.5/weather?q=Amsterdam&units=metric&appid=<REDACTED_API_KEY>`
  - **Method:** `GET`
  - **Headers (optional):**  
    `Accept: application/json`

- **Binary copy:** **ON** (saves the payload exactly as received)

> Tip: keep the API key out of screenshots and the repo. Use `<REDACTED_API_KEY>` in docs.

## Sink (Lakehouse Files)

- **Lakehouse:** `LH_Weather` (adjust to your name)
- **Location:** `Files`

- **Folder path** (partition by trigger time):
  ```text
  @concat(
    'bronze/raw/weather/city=amsterdam/run_date=',
    formatDateTime(pipeline().parameters.run_ts,'yyyy-MM-dd'),
    '/'
  )
  ```

- **File name** (unique per run):
  ```text
  @concat(
    'weather_',
    formatDateTime(pipeline().parameters.run_ts,'yyyyMMdd_HHmmss'),
    '.json'
  )
  ```

**Resulting path example:**

```text
Files/bronze/raw/weather/city=amsterdam/run_date=2025-08-16/weather_20250816_231530.json
```

## Pipeline parameters

Create **1 parameter** so manual/debug runs work and schedules stay deterministic.

- `run_ts` (String)  
  **Default value:**  
  ```text
  @utcNow()
  ```

## Schedule (recommended)

Create a **Schedule** on the pipeline:

- **Cadence:** Hourly (for demo: every 5 minutes)
- **Time zone:** Europe/Amsterdam (or UTC)

**Pass parameter values from the trigger:**

- `run_ts` →  
  ```text
  @trigger().startTime
  ```

This makes folder/file names deterministic based on the scheduled start time.

## Reliability settings

- **Retry:** `3`
- **Timeout:** `00:10:00`
- **Parallel copies:** `1` (default is fine)
- **Data Integration Units (DIUs):** default

## Monitor / validate

After **Run** or a scheduled execution:

- Data Factory → **Monitor** → open the run → **Copy data** output should show:
  - `filesRead = 1`, `filesWritten = 1`
  - `dataWritten ≈ 0.3–1 KB`
- Lakehouse Explorer → **Files → bronze/raw/weather/city=amsterdam/run_date=YYYY-MM-DD/**  
  - A new file like `weather_YYYYMMDD_HHmmss.json` is present  
  - Preview shows valid OpenWeather JSON

## Gotchas

- If you hardcode `trigger().startTime` in expressions **without** the parameter, manual/debug runs will fail (no trigger context). Using `run_ts` avoids this.
- Keep **Binary copy ON** in Bronze; parsing happens later in Silver (Dataflow Gen2).
- Add `units=metric` in the URL to avoid Kelvin temps.
- 401/403 → wrong/missing API key. 429 → too frequent; reduce cadence or add retries.

## Change log

- Initial version (Bronze HTTP → Files, binary, partitioned by `run_date`)