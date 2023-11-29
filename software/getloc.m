% This function takes in the station locations and returns a cell array of
% structs that contain the station locations for each chunk of magnetic
% latitude. The cell array is indexed by MLT == 24 and MLT != 24. The
% structs are indexed by magnetic latitude chunk. The structs contain the
% station locations for that chunk of magnetic latitude. The structs are
% indexed by station ID. The structs contain the station ID, latitude, and
% longitude.
%
% INPUTS:
%   Stations: cell array of station names
%   chunk_size: size of magnetic latitude chunks
%   mlt_all: vector of MLT values for each station
%   maglat_all: vector of magnetic latitudes for each station
%   lat: vector of latitudes for each station
%   long: vector of longitudes for each station
%
% OUTPUTS:
%   LOC: cell array of structs containing station locations
%
function LOC = getloc(Stations, chunk_size, mlt_all, maglat_all, lat, long)
for i = 1:length(mlt_all)/length(Stations) % loop through each time frame
    % temp storage for MLT != 24
    loc_n = [];
    % temp storage for MLT == 24
    loc_m = [];
    % indexes
    loc_n_i = zeros(ceil(180/chunk_size)+1,1) + 1;
    loc_m_i = zeros(ceil(180/chunk_size)+1,1) + 1;
    % loop through each station individually
    % j = index of station
    for j = 1:length(Stations)
        mlt = mlt_all((i-1)*length(Stations)+j);
        maglat = maglat_all((i-1)*length(Stations)+j);
        % decide which maglat chunk the station is in
        maglat_chunk = floor(maglat/chunk_size) + ceil(floor(180/chunk_size)/2)+1;
        % append the station to the correct list
        if mlt <= 1 || mlt >= 23
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Geometry = 'Point';
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Lat = lat(j);
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Lon = long(j);
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).StationID = j;
            loc_m_i(maglat_chunk) = loc_m_i(maglat_chunk) + 1;
        else
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Geometry = 'Point';
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Lat = lat(j);
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Lon = long(j);
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).StationID = j;
            loc_n_i(maglat_chunk) = loc_n_i(maglat_chunk) + 1;
        end
    end
    % append the location struct to the LOC cell array
    LOC{1,i} = loc_m;
    LOC{2,i} = loc_n;
end
end
% struct of LOC
%                  t=1            t=2            t=3            t=4            t=5            t=6            t=7        t=n 
% MLT == 24 -> {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    ...
% MLT != 24 -> {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    ...

% struct of one of the cell
%    -90           -89 ~ -80       -79 ~ -60               80 ~ 90
% {0×0 double}    {1×4 double}    {0×0 double}    ...    {1×5 double}
