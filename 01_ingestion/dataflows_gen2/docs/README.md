# Dataflow Gen2 – Weather API to Lakehouse

**Goal:** Ingest and transform weather data from the OpenWeather API into the Bronze layer of the Lakehouse.

## Overview
- **Source:** OpenWeather API (`https://api.openweathermap.org/data/2.5/weather`)
- **Destination:** Fabric Lakehouse – `bronze_weather`
- **Refresh:** Hourly
- **Purpose:** Feed clean, ready-to-use weather metrics for downstream analytics.

## Build Steps
1. **Create Dataflow Gen2** in Fabric.
2. **Connect to Source:**
   - Connector: REST API
   - Authentication: API key (environment variable)
   - Endpoint example:  
     ```
     https://api.openweathermap.org/data/2.5/weather?q=London&appid=API_KEY
     ```
3. **Transform Data (Power Query):**
   - Keep columns: `temp`, `humidity`, `timestamp`, `city`
   - Convert timestamp to `datetime`
   - Rename columns for consistency (snake_case)
4. **Sink to Lakehouse:**
   - Output table: `bronze_weather`
   - Save in **Bronze** layer folder
5. **Schedule Refresh:**
   - Hourly refresh via Fabric scheduling

## File Exports
- JSON export: [`../weather_dataflow.json`](../weather_dataflow.json)

## Validation
- Verified row count in Lakehouse after refresh
- Sample data query:
```sql
SELECT TOP 10 * 
FROM bronze_weather
ORDER BY timestamp DESC;
```

## Notes

- Keep API key in .env or Fabric connection credential store
- Watch out for API call limits (free tier = 60 calls/min)