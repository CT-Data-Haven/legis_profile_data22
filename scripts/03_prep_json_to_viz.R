# writes to_viz/legis_wide
source("_utils/pkgs.R")

############ DATA ######################################################
# prof_wide has format
# {
#   "bridgeport": {
#     "age": [
#       {
#         "level": "1_state",
#         "location": "Connecticut"
# ...
dist_id <- function(name, house) {
  letter <- toupper(substr(house, 1, 1))
  num <- as.numeric(stringr::str_extract(name, "\\d+"))
  paste0(letter, stringr::str_pad(num, width = 3, side = "left", pad = "0"))
}


prof_wide <- readRDS(file.path("output_data", stringr::str_glue("all_legis_{acs_year}_acs_health_comb.rds"))) |>
  set_names(snakecase::to_snake_case) |>
  map(mutate, across(c(topic, indicator), forcats::as_factor)) |>
  imap(function(df, house) {
    mutate(df, name = ifelse(grepl("District", name), dist_id(name, house), name))
  }) |>
  map(select, -year) |>
  map(rename, location = name) |>
  map(~ split(., .$topic)) |>
  map_depth(2, tidyr::pivot_wider, names_from = indicator) |>
  map_depth(2, select, -topic)

jsonlite::write_json(prof_wide, file.path("to_viz", stringr::str_glue("legis_wide_{acs_year}.json")), auto_unbox = TRUE)
