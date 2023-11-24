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

1. Register for an account at [https://supermag.jhuapl.edu/mag/?tab=register](https://supermag.jhuapl.edu/mag/?tab=register)
2. Go to [https://supermag.jhuapl.edu/mag/?tab=customdownload](https://supermag.jhuapl.edu/mag/?tab=customdownload)
3. Select the time range on the right side of the page
4. select the stations to download
5. Scroll down and choose CSV as the output format
6. keep all other options as default
7. Enter Security Code
8. Click `Download Megnetometer Data`
