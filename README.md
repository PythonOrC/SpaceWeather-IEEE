# Usage

main file is `graphMap.m`

- `TIME`: interger, representing the start time in minutes
- `DURATION`: integer, representing duration of the storm in minutes
- `MAGLAT_CHUNK_SIZE`: integers, representing the size of each station color chunck in degrees
- `DATES`: list of integers, representing time of each frame in minutes from the start of the storm (e.g. {2, 200, 500})
- `ACE_FILE`: string, name of the ACE file with columns
  |YR|MO|DA|HHMM|Day|Day_1|S|Bx|By|Bz|Bt|Lat|Long|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|
- `OBSERVATORY_FILE`: string, name of the file with columns:

| Date_UTC | Extent | IAGA | GEOLON | GEOLAT | MAGLON | MAGLAT | MLT | MCOLAT | IGRF_DECL | SZA | dbn_nez | dbe_nez | dbz_nez | dbn_geo | dbe_geo | dbz_geo |
| -------- | ------ | ---- | ------ | ------ | ------ | ------ | --- | ------ | --------- | --- | ------- | ------- | ------- | ------- | ------- | ------- |
