# writes to_viz/cities
source("_utils/pkgs.R")
library(sf, warn.conflicts = FALSE, quietly = TRUE)
sf::sf_use_s2(FALSE)

############ SHAPEFILES ################################################
# would love a json file of readable topojson, but last time that didn't seem possible
shps <- list(upper = "upper", lower = "lower") |>
  map(\(x) tigris::state_legislative_districts(state = "09", cb = TRUE, house = x, year = 2022)) |>
  map(janitor::clean_names) |>
  map(select, name = tidyselect::matches("^sld.st")) |>
  imap(function(df, house) {
    letter <- toupper(substr(house, 1, 1))
    mutate(df, name = paste0(letter, name))
  }) |>
  map(st_transform, 4326) |>
  map(st_cast, "MULTIPOLYGON")
# topojson_write is deprecated
# iwalk(function(shp, city) {
# geojsonio::topojson_write(shp, object_name = "city", file = file.path("to_viz", "cities", paste(city, "topo.json", sep = "_")))
# })

shps |>
  imap(function(shp, house) {
    geojsonio::geojson_write(shp,
      object_name = "house",
      file = file.path("to_viz", "shapes", paste(house, "topo.json", sep = "_"))
    )
  }) |>
  map(pluck, "path") |>
  walk(function(pth) {
    system(stringr::str_glue("mapshaper {pth} -clean -filter-slivers -o force format=topojson {pth}"))
  })

