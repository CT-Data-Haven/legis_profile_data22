# writes output_data/legislators.rds
# scrape list of legislators and websites
source("_utils/pkgs.R")
library(rvest)

get_meta <- function(row) {
    tds <- rvest::html_elements(row, "td")
    dist <- readr::parse_number(rvest::html_text(tds[1]))
    name <- stringr::str_squish(rvest::html_text(tds[2]))
    website <- rvest::html_attr(rvest::html_element(tds[3], "a"), "href")
    party <- rvest::html_text(tds[4])
    bills_rel <- rvest::html_attr(rvest::html_element(tds[5], "a"), "href")
    dplyr::tibble(dist, name, website, party, bills_rel)
}

set_path <- function(pth, u) {
    urltools::path(u) <- pth
    u
}

read_html_curl <- function(x) {
    cmd <- sprintf("curl '%s' -H 'Accept: text/html'", x)
    html <- system(cmd, intern = TRUE)
    html <- paste(html, collapse = " ")
    rvest::read_html(html)
}

httr::user_agent("Mozilla/5.0 (X11; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0")

base_url <- "https://www.cga.ct.gov"
urls <- list(upper = "s", lower = "h") |>
    map(\(x) stringr::str_glue("asp/menu/{x}list.asp")) |>
    map(set_path, base_url)



# ssl certificate error using curl package, but works from system
# collapse into single html document to read
legs <- urls |>
    map(read_html_curl) |>
    map(html_element, "table") |>
    map(html_elements, "tbody tr") |>
    map(\(x) map_dfr(x, get_meta)) |>
    bind_rows(.id = "house") |>
    mutate(letter = toupper(substr(house, 1, 1))) |>
    mutate(id = sprintf("%s%03d", letter, dist)) |>
    tidyr::separate_wider_delim(name, ", ", names = c("last_name", "first_name")) |>
    mutate(bills = map_chr(bills_rel, set_path, base_url)) |>
    split(~house) |>
    map(select, -house, -bills_rel, -letter) |>
    map(relocate, id)


# district-town lookup
town_dist <- read_html_curl("https://www.cga.ct.gov/asp/content/townlist.asp") |>
    html_table() |>
    pluck(1) |>
    janitor::clean_names() |>
    select(town, house_districts, senate_districts) |>
    tidyr::pivot_longer(-town, names_to = c("house", NA), names_sep = "_", values_to = "dist") |>
    mutate(house = forcats::as_factor(house) |>
        forcats::fct_recode(upper = "senate", lower = "house")) |>
    mutate(dist = stringr::str_extract_all(dist, "\\d+") |>
        map(as.numeric)) |>
    tidyr::unnest(dist) |>
    mutate(letter = toupper(substr(house, 1, 1))) |>
    mutate(id = sprintf("%s%03d", letter, dist)) |>
    split(~house) |>
    map(select, id, town)



saveRDS(legs, "_utils/legislators.rds")
saveRDS(town_dist, "_utils/town_dist_xwalk.rds")

