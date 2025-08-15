// silver_weather_sample.m
// Function: parse ONE OpenWeather "current weather" JSON (binary) -> 1-row typed table
// Usage: in a Dataflow Gen2, add a Blank query, rename to fnParseOpenWeatherCurrent, open Advanced Editor, paste this.
(let bin as binary) as table =>
let
    // Load JSON
    src           = Json.Document(bin),
    recToTable    = Record.ToTable(src),
    transposed    = Table.Transpose(recToTable),
    promoted      = Table.PromoteHeaders(transposed, [PromoteAllScalars=true]),

    // Expand nested structures (defensively in case fields are missing)
    expSys        = if Table.HasColumns(promoted, "sys")     then Table.ExpandRecordColumn(promoted, "sys",     {"country"}, {"country"}) else promoted,
    expClouds     = if Table.HasColumns(expSys, "clouds")    then Table.ExpandRecordColumn(expSys, "clouds",    {"all"},    {"clouds_all"}) else expSys,
    expWind       = if Table.HasColumns(expClouds, "wind")   then Table.ExpandRecordColumn(expClouds, "wind",   {"speed","deg"}, {"wind_speed","wind_deg"}) else expClouds,
    expMain       = if Table.HasColumns(expWind, "main")     then Table.ExpandRecordColumn(expWind, "main",     {"temp","feels_like","temp_min","temp_max","pressure","humidity"}, {"temp","feels_like","temp_min","temp_max","pressure","humidity"}) else expWind,
    expWeatherL   = if Table.HasColumns(expMain, "weather")  then Table.ExpandListColumn(expMain, "weather") else expMain,
    expWeather    = if Table.HasColumns(expWeatherL, "weather") then Table.ExpandRecordColumn(expWeatherL, "weather", {"main","description"}, {"weather_main","weather_description"}) else expWeatherL,
    expCoord      = if Table.HasColumns(expWeather, "coord") then Table.ExpandRecordColumn(expWeather, "coord", {"lon","lat"}, {"lon","lat"}) else expWeather,

    // Compute timestamp + date from Unix 'dt' (seconds)
    withTs        = if Table.HasColumns(expCoord, "dt")
                    then Table.AddColumn(expCoord, "timestamp", each #datetime(1970,1,1,0,0,0) + #duration(0,0,0, [dt]), type datetime)
                    else Table.AddColumn(expCoord, "timestamp", each null, type datetime),
    withDate      = Table.AddColumn(withTs, "date", each try Date.From([timestamp]) otherwise null, type date),

    // Keep curated columns only
    keepCols      = Table.SelectColumns(
                        withDate,
                        {"name","country","lat","lon","timestamp","date",
                         "temp","feels_like","temp_min","temp_max",
                         "pressure","humidity","wind_speed","wind_deg",
                         "clouds_all","visibility","weather_main","weather_description"},
                        MissingField.UseNull
                    ),

    // Strong types
    typed         = Table.TransformColumnTypes(
                        keepCols,
                        {
                          {"name", type text}, {"country", type text},
                          {"lat", type number}, {"lon", type number},
                          {"timestamp", type datetime}, {"date", type date},
                          {"temp", type number}, {"feels_like", type number},
                          {"temp_min", type number}, {"temp_max", type number},
                          {"pressure", Int64.Type}, {"humidity", Int64.Type},
                          {"wind_speed", type number}, {"wind_deg", Int64.Type},
                          {"clouds_all", Int64.Type}, {"visibility", Int64.Type},
                          {"weather_main", type text}, {"weather_description", type text}
                        }
                    )
in
    typed
)