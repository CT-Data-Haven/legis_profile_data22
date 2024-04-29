source("_utils/pkgs.R")

############ HEADINGS ##################################################
hdr_files <- c("acs_indicator_headings.txt", "cdc_indicators.txt")
hdr_paths <- file.path("_utils", hdr_files)

# set_names(hdr_files) |>
#   map(~ gh::gh("/repos/{owner}/{repo}/contents/meta/{path}", owner = "ct-data-haven", repo = "scratchpad", path = .)) |>
#   map(~ .[c("download_url", "name")]) |>
#   bind_rows() |>
#   mutate(file = file.path("_utils", name)) |>
#   pwalk(function(download_url, name, file) download.file(download_url, file))

headings <- hdr_paths |>
  set_names(basename) |>
  set_names(stringr::str_extract, "^[a-z]+") |>
  map_dfr(readr::read_csv, show_col_types = FALSE, .id = "dataset") |>
  mutate(
    display = coalesce(new_display, display),
    type = stringr::str_extract(indicator, "^([a-z]+)(?=\\s)") |>
      as_factor() |>
      fct_recode(t = "estimate", m = "share") |>
      fct_na_value_to_level(level = "m"),
    topic = as_factor(topic) |>
      fct_recode(health_risk_behaviors = "behaviors", health_outcomes = "outcomes", life_expectancy = "expectancy"),
    format = case_when(
      grepl("life_exp", indicator)   ~ ".1f",
      type == "t"                    ~ ",",
      # type == "m"                  ~ ".0%",
      type == "m" & dataset == "cdc" ~ ".1%",
      type == "m"                    ~ ".0%",
      TRUE                           ~ ","
    ),
    topic_display = topic |>
      fct_relabel(camiller::clean_titles) |>
      fct_relabel(stringr::str_replace, "(?<=Income)(\\s)", " by age: ") |>
      fct_recode("Race and ethnicity" = "Race"),
    indicator = stringr::str_remove(indicator, "^[a-z]+\\s") |>
      as_factor() |>
      fct_relevel("ages18plus", after = 2)
  ) |>
  arrange(topic, indicator, type) |>
  tidyr::unite(col = indicator, type, indicator, sep = "X", remove = FALSE) |>
  select(topic, topic_display, indicator, type, display, format)

headings_json <- headings |>
  split(~topic) |>
  map(function(topic_df) {
    indicator_df <- select(topic_df, -topic, -topic_display)
    list(
      display = as.character(unique(topic_df$topic_display)),
      indicators = indicator_df
    )
  })

# rename from nhood_meta.json
jsonlite::write_json(headings_json, file.path("to_viz", "indicators.json"), auto_unbox = TRUE)