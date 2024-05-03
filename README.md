# Data for legislative district profiles–2022 ACS, 2023 PLACES


# README

Sources for the profile data are the most recent ACS (2022), CDC PLACES
(2023 release), and USALEEP (not updated). There’s no fresh analysis
done in this repo—this is a way to assemble data from other projects
with readable headings and descriptions, and prep it for each city’s
neighborhood profiles and online visualization.

Datasets prepped for download from other repos are in their respective
tagged releases to ensure their stability and reproduceability. Not all
assets from each tag are used, but the files in those releases are:

| repo       | tag                                                                   | updated              | assets                                                                |
|:-----------|:----------------------------------------------------------------------|:---------------------|:----------------------------------------------------------------------|
| 2022acs    | [dist](https://github.com/CT-Data-Haven/2022acs/releases/tag/dist)    | 2024-04-29T21:13:52Z | acs_nhoods_by_city_2022.rds, acs_town_basic_profile_2022.rds          |
| cdc_aggs   | [v2023](https://github.com/CT-Data-Haven/cdc_aggs/releases/tag/v2023) | 2024-04-25T22:16:50Z | cdc_health_all_lvls_nhood_2023.rds, cdc_health_all_lvls_wide_2023.csv |
| scratchpad | [meta](https://github.com/CT-Data-Haven/scratchpad/releases/tag/meta) | 2024-03-21T20:35:46Z | acs_headings_extra.txt, acs_indicator_headings.txt                    |
| scratchpad | [meta](https://github.com/CT-Data-Haven/scratchpad/releases/tag/meta) | 2024-04-05T18:22:05Z | cdc_indicators.txt                                                    |

This uses snakemake to build. Rules available are:

    all
    clean
    combine_datasets
    distro
    download_data
    headings
    legislators
    make_shapes
    notes
    readme
    sync_to_dw
    upload_shapes
    upload_viz_data
    viz_data

Build process is as follows:

    Building DAG of jobs...

![snakemake DAG](dag.png)
