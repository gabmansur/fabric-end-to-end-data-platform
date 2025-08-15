-- Fabric SQL tip: run this CREATE/ALTER VIEW by itself (as the only statement in the batch)
CREATE OR ALTER VIEW dbo.VW_Weather_Readings AS
SELECT
  file_name,
  run_date,
  name          AS city_name,
  [timestamp]   AS ts_utc,
  temp, feels_like, humidity, pressure,
  wind_speed, clouds_all,
  weather_main, weather_description
FROM dbo.silver_weather;
