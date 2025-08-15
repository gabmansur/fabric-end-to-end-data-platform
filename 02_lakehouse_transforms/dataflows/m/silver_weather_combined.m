// silver_weather_combined.m
// Query: combine ALL OpenWeather JSON files from Bronze and parse with fnParseOpenWeatherCurrent()
// Usage: in a Dataflow Gen2, add a Blank query, rename to silver_weather, open Advanced Editor, paste this.
// NOTE: replace the workspaceId and lakehouseId values with yours, and adjust the city folder if needed.

let
    // ---- IDs (replace with your own) ----
    workspaceId  = "<REPLACE_WORKSPACE_ID>",
    lakehouseId  = "<REPLACE_LAKEHOUSE_ID>",

    // ---- Navigate to Lakehouse Files/Bronze path ----
    Source       = Lakehouse.Contents(null),
    WS           = Source{[workspaceId = workspaceId]}[Data],
    LH           = WS{[lakehouseId = lakehouseId]}[Data],
    FilesRoot    = LH{[Id = "Files", ItemKind = "Folder"]}[Data],

    Bronze       = FilesRoot{[Name = "bronze"]}[Content],
    Raw          = Bronze{[Name = "raw"]}[Content],
    Weather      = Raw{[Name = "weather"]}[Content],
    CityFolder   = Weather{[Name = "city=amsterdam"]}[Content],  // change if you ingest multiple cities

    // ---- Flatten run_date subfolders to get a files list (Binary) ----
    Expanded     = Table.ExpandTableColumn(
                     CityFolder, "Content",
                     {"Content","Name","Extension","Date modified","Folder Path"},
                     {"Content.1","Name.1","Extension.1","DateModified.1","FolderPath.1"}
                   ),
    Keep         = Table.SelectColumns(Expanded, {"Content.1","Name.1","FolderPath.1"}),

    // ---- Parse each file using the function (paste sample function as fnParseOpenWeatherCurrent) ----
    ParsedCol    = Table.AddColumn(Keep, "Parsed", each fnParseOpenWeatherCurrent([Content.1])),

    // ---- Expand parsed columns (use the function's output schema) ----
    ExpandedParsed = Table.ExpandTableColumn(
                       ParsedCol, "Parsed",
                       {"name","country","lat","lon","timestamp","date",
                        "temp","feels_like","temp_min","temp_max",
                        "pressure","humidity","wind_speed","wind_deg",
                        "clouds_all","visibility","weather_main","weather_description"}
                     ),

    // ---- Lineage + partition ----
    WithFileName = Table.RenameColumns(ExpandedParsed, {{"Name.1","file_name"}}),
    WithPathText = Table.AddColumn(WithFileName, "FolderPathText", each try Uri.UnescapeDataString([FolderPath.1]) otherwise [FolderPath.1], type text),
    WithRunDate  = Table.AddColumn(WithPathText, "run_date", each let fp = [FolderPathText] in try Date.From(Text.BetweenDelimiters(fp, "run_date=", "/")) otherwise null, type date),

    // ---- Final projection ----
    Silver       = Table.SelectColumns(
                     WithRunDate,
                     {"file_name","run_date",
                      "name","country","lat","lon","timestamp","date",
                      "temp","feels_like","temp_min","temp_max",
                      "pressure","humidity","wind_speed","wind_deg",
                      "clouds_all","visibility","weather_main","weather_description"},
                     MissingField.UseNull
                   ),

    // ---- Optional: enforce types (parser already sets most) ----
    Typed        = Table.TransformColumnTypes(
                     Silver,
                     {
                      {"file_name", type text}, {"run_date", type date},
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
    Typed
