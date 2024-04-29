#!/usr/bin/env bash
acsyr=$1
cdcyr=$2

# download assets from latest releases of cdc_aggs (tagged v$cdcyr) and $acsyracs (tagged dist)
# comparable to input_data/acs_nhoods_by_city_$(YR).rds input_data/cdc_health_all_lvls_nhood_$(YR).rds 
acsrepo="CT-Data-Haven/$1acs"
cdcrepo="CT-Data-Haven/cdc_aggs"
scratchrepo="CT-Data-Haven/scratchpad"

acstag="dist"
cdctag="v$cdcyr"
scratchtag="meta"

gh release download "$acstag" \
  --repo "$acsrepo" \
  --pattern "*.rds" \
  --dir input_data \
  --clobber

gh release download "$cdctag" \
  --repo "$cdcrepo" \
  --pattern "*.rds" \
  --dir input_data \
  --clobber

gh release download "$scratchtag" \
  --repo "$scratchrepo" \
  --pattern "acs_indicator_headings.txt" --pattern "cdc_indicators.txt" \
  --dir _utils \
  --clobber

gh release view "$scratchtag" \
  --repo "$scratchrepo" \
  --json id,tagName,assets,createdAt,url > \
  .meta_downloaded.json