# Usage

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

## Running the Code

To run the code, use the following procedure:

1. Download the data using the procedure above
2. edit the `graphMap.m` file to point `OBSRVATORY_FILE` parameter to the correct data file
3. run the `graphMap.m` file

## Output

The file `graphMap.m` will output a map of the stations and the data points that were downloaded. The data points are color coded based on the magnitude of the magnetic field at that point. The color scale is shown on the right side of the map. The map is saved as a `.png` file in the `figures` folder in the same directory as the `graphMap.m` file.
