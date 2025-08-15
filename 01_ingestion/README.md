# 01 — Ingestion (Bronze)

**What & Why**  
Pull raw data into the Lakehouse **as-is** (schema-on-read) to keep ingestion robust and auditable. We ingest OpenWeather current conditions hourly.

**Architecture (this slice)**  
API (HTTP) → Data Factory (**Copy**, Binary) → Lakehouse **Files**  
`Files/bronze/raw/weather/city=amsterdam/run_date=YYYY-MM-DD/weather_YYYYMMDD_HHmmss.json`

**Artifacts**
- Pipeline: `pipelines/PL_Weather_API_ToBronze.md` (params & expressions)
- Sample JSON: `datasets/sample_weather.json` (tiny)
- Notes: `docs/day1_ingestion.md` (gotchas + screenshots)

**How to Run**
1. Create Lakehouse `LH_Weather`.
2. Pipeline **Copy data** (HTTP → Lakehouse Files)  
   - Base URL: `https://api.openweathermap.org`  
   - Relative: `/data/2.5/weather?q=Amsterdam&units=metric&appid=<API_KEY>`  
   - **Binary copy: ON**
3. Sink path (expressions):  
   - Folder: `@concat('bronze/raw/weather/city=amsterdam/run_date=', formatDateTime(utcNow(),'yyyy-MM-dd'), '/')`  
   - File:   `@concat('weather_', formatDateTime(utcNow(),'yyyyMMdd_HHmmss'), '.json')`
4. **Debug** → verify file in Lakehouse Files.
5. **Schedule**: every hour (or every 5 min for demo).

**Schedule & Monitoring**
- Pipeline schedule: hourly; monitor in **Data Factory → Monitor** (filesWritten ≈ 1, dataWritten ≈ 0.3–1 KB).
- Failures: check HTTP 401/429; add retry = 3, timeout = 10m.

**Gotchas**
- Keep **Binary** in Bronze; don’t try to parse here.
- Never commit secrets; use placeholders in docs.
- Case-sensitive folder names; keep `run_date=YYYY-MM-DD` consistent.

**Next**
Go to **02 — Lakehouse transforms (Silver)** to combine files and parse JSON with Dataflow Gen2.