#!/usr/bin/env bash
files="$@"
mkdir -p ../scratchpad/geography/legis
cp -t ../scratchpad/geography/legis $files
cd ../scratchpad
git add geography
git commit -m "Update topojson files - legislative districts"
git push

if ! gh release view geos-legis > /dev/null 2>&1; then
  gh release create geos-legis --title "Legislative district shapefiles" --notes ""
fi

# return to previous directory
cd -

gh release upload geos-legis \
  $files \
  --repo "CT-Data-Haven/scratchpad" \
  --clobber 

gh release view geos-legis \
  --repo "CT-Data-Haven/scratchpad" \
  --json id,tagName,assets,createdAt,url > \
  .shapes_uploaded.json