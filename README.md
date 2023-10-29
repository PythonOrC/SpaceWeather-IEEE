# Usage

## Parameters

main file is `graphMap.m`

- `TIME`: interger, representing the start time in minutes
- `DURATION`: integer, representing duration of the storm in minutes
- `MAGLAT_CHUNK_SIZE`: integers, representing the size of each station color chunck in degrees
- `DATES`: list of integers, representing time of each frame in minutes from the start of the storm (e.g. {2, 200, 500})
- `OBSERVATORY_FILE`: string, name of the file with columns:

| Date_UTC | Extent | IAGA | GEOLON | GEOLAT | MAGLON | MAGLAT | MLT | MCOLAT | IGRF_DECL | SZA | dbn_nez | dbe_nez | dbz_nez | dbn_geo | dbe_geo | dbz_geo |
| -------- | ------ | ---- | ------ | ------ | ------ | ------ | --- | ------ | --------- | --- | ------- | ------- | ------- | ------- | ------- | ------- |

## Data Download Procedure

To download the `OBSERVATORY_FILE` data, use the following procedure:

1. Go to [https://supermag.jhuapl.edu/mag/?tab=customdownload](https://supermag.jhuapl.edu/mag/?tab=customdownload)
2. Select the time range on the right side of the page
3. select the stations you want to download
4. keep all other options as default
5. scroll down and click `Download Megnetometer Data`
6. place downloaded csv file in the same directory as `graphMap.m`