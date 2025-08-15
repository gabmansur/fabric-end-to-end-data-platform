-- Fabric SQL tip: run this CREATE/ALTER VIEW by itself (as the only statement in the batch)
CREATE OR ALTER VIEW dbo.VW_Weather_Hourly AS
SELECT
  sw.name AS city_name,
  DATEADD(hour, DATEDIFF(hour, 0, sw.[timestamp]), 0) AS hour_start_utc,
  COUNT(*)           AS n_obs,
  AVG(sw.temp)       AS avg_temp_c,
  MIN(sw.temp)       AS min_temp_c,
  MAX(sw.temp)       AS max_temp_c,
  AVG(sw.feels_like) AS avg_feels_like_c,
  AVG(sw.humidity)   AS avg_humidity,
  AVG(sw.pressure)   AS avg_pressure,
  AVG(sw.wind_speed) AS avg_wind_speed,
  AVG(sw.clouds_all) AS avg_clouds
FROM dbo.silver_weather sw
GROUP BY
  sw.name,
  DATEADD(hour, DATEDIFF(hour, 0, sw.[timestamp]), 0);
