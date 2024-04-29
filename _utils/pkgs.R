# prep_utils <- function(x = NULL) {
#   library(dplyr, warn.conflicts = FALSE,   quietly = TRUE)
#   library(purrr, warn.conflicts = FALSE,   quietly = TRUE)
#   library(forcats, warn.conflicts = FALSE, quietly = TRUE)

#   default_acs_yr <- 2022
#   default_cdc_yr <- 2023

#   if (interactive()) {
#     cli::cli_h1("Interactive")
#     yr <- default_acs_yr
#     cdc_yr <- default_cdc_yr
#   } else if (exists("snakemake") && length(snakemake@params) > 0) {
#     cli::cli_h1("From snakemake")
#     yr <- as.numeric(snakemake@params[["acs_year"]])
#     cdc_yr <- as.numeric(snakemake@params[["cdc_year"]])
#   } else {
#     cli::cli_h1("From command line")
#     prsr <- argparse::ArgumentParser()

#     prsr$add_argument("yr", help = "Main profile year")
#     prsr$add_argument("cdc_yr", help = "CDC PLACES release year")

#     args <- prsr$parse_args()
#     yr <- as.numeric(args$yr)
#     cdc_yr <- as.numeric(args$cdc_yr)
#   }

#   yr_str <- substr(as.character(yr), 3, 4)

#   # 2 neighborhood names are duplicated across cities--all have downtown, bpt & stam have South End
#   dupe_nhoods <- c("Downtown", "South End")

#   list(yr = yr, cdc_yr = cdc_yr, yr_str = yr_str, dupe_nhoods = dupe_nhoods)
# }

library(dplyr, warn.conflicts = FALSE, quietly = TRUE)
library(purrr, warn.conflicts = FALSE, quietly = TRUE)
library(forcats, warn.conflicts = FALSE, quietly = TRUE)
# dupe_nhoods <- c("Downtown", "South End")

if (exists("snakemake")) {
    acs_year <- snakemake@params[["acs_year"]]
    cdc_year <- snakemake@params[["cdc_year"]]
} else {
    acs_year <- 2022
    cdc_year <- 2023
}
