#!/usr/bin/env bash
key="$1"
year="$2"
# read in as array
shift 2
files=$@

owner="ctdatahaven"
dataset="datahaven-profiles-$year"
# get last 2 characters of $year
yearstr="${year: -2}"
repo="nhood_profile_data$yearstr"

baseurl="https://api.data.world/v0/datasets/$owner/$dataset"
url1="$baseurl/files"

prepurl() {
  csv=$(basename "$1")
  city=$(echo "$csv" | sed -E "s/_nhood.+//")
  name=$(echo "$city" | sed -e "s/_/ /g" | sed -E "s/\b([a-z])/\U\1/g")
  desc="ACS basic indicators, CDC life expectancy estimates, PLACES Project averages, $name"
  url="https://github.com/CT-Data-Haven/$repo/blob/main/to_distro/$csv"
  json=$(jq -n --arg source "$url" --arg description "$desc" --arg name "$csv" \
    '{source: {url: $source}, description: $description, name: $name}')
  echo $json
}

# call prepurl for each file in $files and get as array for jq
jsons=()
for file in $files; do
  jsons+=("$(prepurl $file)")
done

# join array with comma
# use $query as data argument in curl
query="{\"files\": [$(IFS=,; echo "${jsons[*]}")]}"
curl --request POST \
     --url "https://api.data.world/v0/datasets/$owner/$dataset/files" \
     --header "accept: application/json" \
     --header "authorization: Bearer $key" \
     --header "content-type: application/json" \
     --data "$query"



curl --request GET \
  --url "$baseurl" \
  --header "accept: application/json" \
  --header "authorization: Bearer $key" > \
  .dw_uploaded.json

# api takes files in form '
# {
#   "files": [
#     {
#       "source": {
#         "url": "https://github.com/CT-Data-Haven/nhood_profile_data22/blob/main/to_distro/stamford_nhood_2022_acs_health_comb.csv"
#       },
#       "description": "test file",
#       "name": "stamford_nhood_2022_acs_health_comb.csv"
#     }
#   ]
# }
# '