# reads _utils/town_dist_xwalk, _utils/legislators, _utils/manual/sources
# writes to_viz/notes.json, to_viz/members.json
source("_utils/pkgs.R")

# need:
# * town-district xwalk, nested by district
# * legislator metadata
# * sources
xwalk <- readRDS("_utils/town_dist_xwalk.rds") |>
  bind_rows(.id = "house") |>
  tidyr::nest(.by = c("house", "id"), .key = "towns") |>
  mutate(towns = map(towns, pull))

members <- readRDS("_utils/legislators.rds")  |>
  bind_rows(.id = "house")

sources <- readr::read_delim("_utils/manual/sources.txt", delim = ";", show_col_types = FALSE)

members <- inner_join(xwalk, members, by = c("house", "id")) |>
  arrange(house, id) |>
  split(~house) |>
  map(select, -house, -dist)


notes <- list(
  sources = sources, 
  # dwurls = urls,
  NULL
)
jsonlite::write_json(notes, file.path("to_viz", "notes.json"), auto_unbox = TRUE)

jsonlite::write_json(members, "to_viz/members.json", auto_unbox = TRUE)