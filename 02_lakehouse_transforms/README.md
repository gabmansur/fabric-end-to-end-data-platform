# 02 — Lakehouse Transforms (Silver)

**What & Why**  
Standardize raw JSON into a typed table. We **flatten** `run_date` subfolders, **Combine files**, and parse OpenWeather JSON into `dbo.silver_weather`.

**Architecture (this slice)**  
Files (Bronze) → **Dataflow Gen2** (Combine files + sample transform) → Lakehouse **Table** `dbo.silver_weather`

**Artifacts**
- M (sample parser): `dataflows/silver_weather_sample.m`
- M (combined query): `dataflows/silver_weather_combined.m`
- Notes: `docs/silver_gotchas.md`

**How to Run**
1. Dataflow Gen2 → Get Data → Lakehouse → `/Files/bronze/raw/weather/city=amsterdam/`
2. Expand **Content** (subfolders) to get a **files list (Binary)** → **Combine files**.
3. In **Transform Sample File**:
   - Expand `main`, `wind`, `clouds`, `coord`, `weather`  
   - Add `timestamp = #datetime(1970,1,1,0,0,0) + #duration(0,0,0,[dt])` and `date = Date.From([timestamp])`
   - Set explicit types
4. In the **combined query**:
   - Add `file_name = Source.Name`
   - `run_date = Date.From(Text.BetweenDelimiters(Uri.UnescapeDataString([Source.Folder Path]), "run_date=", "/"))`
   - Keep curated columns only
5. Output → `dbo.silver_weather` (Append) → **Refresh now**.

**Schedule & Monitoring**
- Either schedule the dataflow **+5 min** after the pipeline, or trigger it from the pipeline.
- Use **Run history** to verify row counts.

**Gotchas**
- Combine appears only when the column is **Content (Binary)**.
- Avoid `Any` types; map Text/Number/Date explicitly.
- If `run_date` = null, unescape the path first (`Uri.UnescapeDataString`).

**Next**
03 — Create **Gold views** (hourly/daily rollups).
