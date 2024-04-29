# writes output_data/all_nhood_yr_acs_health_comb.rds
source("_utils/pkgs.R")

# geos <- readRDS(file.path("_utils", "city_geos.rds"))

# datasets need indicators as tXother_race, mXasthma to match meta
acs <- readRDS(file.path("input_data", stringr::str_glue("acs_town_basic_profile_{acs_year}.rds"))) |>
  mutate(level = fct_relabel(level, \(x) stringr::str_remove(x, "^\\d_"))) |>
  mutate(year = acs_year) |> # not sure where this got lost
  filter(level %in% c("upper_legis", "lower_legis", "state")) |>
  select(level, topic, name, year, indicator = group, estimate, share) |>
  tidyr::pivot_longer(estimate:share, names_to = "type", values_drop_na = TRUE) |>
  mutate(
    type = fct_recode(type, t = "estimate", m = "share"),
    year = as.character(year)
  )

# add comparison locations to nhoods for cdc data
cdc <- readRDS(file.path("input_data", stringr::str_glue("cdc_health_all_lvls_nhood_{cdc_year}.rds"))) |>
  filter(level %in% c("upper_legis", "lower_legis", "state")) |>
  select(level, topic, name, year, indicator = question, value) |>
  mutate(
    type = factor("m"),
    indicator = indicator |>
      fct_relabel(snakecase::to_snake_case) |>
      fct_recode(
        checkup = "annual_checkup",
        heart_disease = "coronary_heart_disease",
        asthma = "current_asthma",
        blood_pressure = "high_blood_pressure",
        dental = "dental_visit",
        smoking = "current_smoking",
        sleep = "sleep_7_hours",
        life_exp = "life_expectancy",
        insurance = "health_insurance"
      )
  ) |>
  mutate(topic = fct_recode(topic, health_outcomes = "life_expectancy"))


out_df <- bind_rows(acs, cdc) |>
  # inner_join(geos, by = c("city", "name")) |>
  mutate(name = stringr::str_replace(name, "\\bOf\\b", "of")) |>
  mutate(topic = case_when(
    topic == "pov_age" & grepl("00_17", indicator) ~ "income_children",
    topic == "pov_age" & grepl("65", indicator) ~ "income_seniors",
    TRUE ~ topic
  ) |>
    as_factor() |>
    fct_recode(
      health_risk_behaviors = "RISKBEH",
      health_outcomes = "HLTHOUT",
      prevention = "PREVENT",
      immigration = "foreign_born",
      income = "poverty",
      disability = "DISABLT"
    ) |>
    fct_collapse(housing = c("housing_cost", "tenure"))) |>
  tidyr::unite(col = indicator, type, indicator, sep = "X") |>
  filter(topic != "sex") |>
  mutate(across(where(is.factor), fct_drop)) 

# multiple "total_households" as different denoms for housing (tenure, burden)
out_by_house <- list(upper = "upper_legis", lower = "lower_legis") |>
  map(\(x) filter(out_df, level %in% c("state", x))) |>
  map(arrange, topic, level, name) |>
  map(distinct, level, topic, name, year, indicator, .keep_all = TRUE)

saveRDS(out_by_house, file.path("output_data", stringr::str_glue("all_legis_{acs_year}_acs_health_comb.rds")))
