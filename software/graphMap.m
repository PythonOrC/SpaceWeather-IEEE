clear
%================MUST CONFIGURE================
TIME = 309;
DURATION = 240;                                                 % duration of the generation in minutes starting from TIME (240 = 4 hours starting from TIME)
DATES = {371,376,409,483};                                      % dates to generate (empty or undefined = all dates)
OBSERVATORY_FILE = "data/sample/20231029-00-07-supermag.csv";   % path to the observatory file downloaded from supermag
CBAR_COVERAGE = [0.5 99.5];                                     % colorbar coverage in percentile, [0.5 99.5] means 0.5% to 99.5% percentile, range = [0,100]
%==============================================
clc

%================OPTIONAL CONGURATION================
lat_range = [-90 90];               % latitude range of the display area in degrees
long_range = [-180 180];            % longitude range of the display area in degrees
fig_position = [10 10 600 400]      % position of the figure window in pixels [left bottom width height]
chunk_size = 10;                    % size of the color chunks of magnetic latitude (10 = alternate color every 10 degrees)
load("colormap.mat");               % load the colormap
s = shaperead('landareas.shp');     % load the shape file
%====================================================

%declare variables
data_dbn = {};
data_dbe = {};
data_dbh = {};
dat_dbn = [];
dat_dbe = [];
dat_dbh = [];
LOC={};

% preprocess the downloaded csv to remove stations that are too unreliable
processed_file_path = preprocess(OBSERVATORY_FILE, TIME, DURATION);
raw = readtable(processed_file_path, "Delimiter",",", "DatetimeType","datetime");

% generate the dates to generate
if exist('DATES','var') && ~isempty(DATES) % if DATES is defined
    for i = 1: length(DATES)
        DATES{i} = DATES{i}+1-TIME;
    end
else % if DATES is not defined
    DATES = cell(1,DURATION);
    for i = 1:DURATION
        DATES{i} = i;
    end
end

% get the stations from the raw data
[Stations,IA,IC] = unique(raw.IAGA, 'stable');
mlt_all = raw.MLT;
maglat_all = raw.MAGLAT;

% get the latitude and longitude of each station
lat = raw.GEOLAT(1:length(Stations), 1);
long = raw.GEOLON(1:length(Stations), 1);
for i = 1:length(long)
    if long(i) > 180
        long(i) = long(i)-360;
    end
end

% extract the necessary data from the raw data
for i = 1:length(Stations)
    % raw datum refers to all the data from a single station
    raw_datum = raw(raw.IAGA == string(Stations(i)), :);
    % extract the needed datum from the raw datum
    datum_dbn = table2array(raw_datum(:,{'dbn_nez'}));
    datum_dbe = table2array(raw_datum(:,{'dbe_nez'}));
    % add the datum to the data cell array
    data_dbn = [data_dbn; datum_dbn];
    data_dbe = [data_dbe; datum_dbe];

    %calculate dbh
    for j = 1:length(datum_dbn)
        dbh = sqrt(datum_dbn(j)^2 + datum_dbe(j)^2);
        % assign the dbh to the correct signage
        if datum_dbn(j) < 0
            dbh = -dbh;
        end
        datum_dbh(j) = dbh;
    end
    data_dbh = [data_dbh; datum_dbh'];
end

% generate the location struct for each time step
for i = 1:length(raw.MLT)/length(Stations)
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
% struct of LOC
%                  t=1            t=2            t=3            t=4            t=5            t=6            t=7        t=n 
% MLT == 24 -> {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    ...
% MLT != 24 -> {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    ...

% struct of one of the cell
%    -90           -89 ~ -80       -79 ~ -60               80 ~ 90
% {0×0 double}    {1×4 double}    {0×0 double}    ...    {1×5 double}

% combine the data and the Stations together into a table
OBS = table(Stations, data_dbn, lat, long, data_dbe, data_dbh);
%resulting sample structure of all:
    % Stations       data_dbn        lat       long        data_dbe            data_dbh      
    % ________    _______________    _____    _______   _______________     _______________
    % {'BOU'}     {1440×1 double}    40.14    -105.24   {1440×1 double}     {1440×1 double}
    % {'BSL'}     {1440×1 double}    30.35     -89.64   {1440×1 double}     {1440×1 double}
    % {'FRD'}     {1440×1 double}     38.2     -77.37   {1440×1 double}     {1440×1 double}
    % {'FRN'}     {1440×1 double}    37.09    -119.72   {1440×1 double}     {1440×1 double}
    % {'NEW'}     {1440×1 double}    48.27    -117.12   {1440×1 double}     {1440×1 double}

%combine all dbh values into a 2d array
for i = 1:length(OBS.Stations)
    dat_dbh = [dat_dbh OBS(strcmp(OBS.Stations, OBS.Stations(i)), : ).data_dbh{1}];
end

%get the upper and lower bounds of the data
min_dbh = prctile(dat_dbh, CBAR_COVERAGE(1), 'all');
max_dbh = prctile(dat_dbh, CBAR_COVERAGE(2), 'all');

%Use meshgrid to create a set of 2-D grid points in the longitude-latitude plane and then use griddata to interpolate the corresponding depth at those points:
[longi,lati] = meshgrid(long_range(1):1:long_range(2), lat_range(1):1:lat_range(2)); % * 0.5 is the resolution, longitude then latitude
[longi,lati] = meshgrid(long_range(1):0.5:long_range(2), lat_range(1):0.5:lat_range(2)); % * 0.5 is the resolution, longitude then latitude

% graph the data
for idx = 1:length(DATES)
    t = DATES{idx};
    fprintf("Generating %d max: %d min: %d\n", t, max_dbh, min_dbh);
    dat_dbh_c = dat_dbh(t,:); % _c = current data for all stations
    v = variogram([OBS.long OBS.lat],dat_dbh_c');
    [~,~,~,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable');
    close;
    [OBSi,OBSVari] = kriging(vstruct,OBS.long',OBS.lat',dat_dbh_c,longi,lati);
    
    figure('Color','w', 'Position',[0 0 1280 720]);

    h=pcolor(longi,lati,OBSi); % * draw the points
    hold on
    set(h,'EdgeColor','none'); 
        
    % draw the stations diffferently depending on MLT
    % draw the stations with MLT == 24
    for i = 1:length(LOC{2,t})
        if ~isempty(LOC{2,t}{i})
            if i/2 ~= floor(i/2)
                station_color = [0 0 0];
            else
                station_color = [1 1 1];
            end
            geoshow(LOC{2,t}{i},'Marker','o',...
            'MarkerFaceColor',station_color,'MarkerEdgeColor','k', 'MarkerSize', 5);
        end
    end
    % draw the stations with MLT != 24
    for i = 1:length(LOC{1,t})
        if ~isempty(LOC{1,t}{i})
            geoshow(LOC{1,t}{i},'Marker','d',...
            'MarkerFaceColor',[1 0 1],'MarkerEdgeColor','k', 'MarkerSize', 5);
        end
    end
    
    % draw the map
    mapshow(s,'FaceAlpha', 0);
    xlabel('Longitude'), ylabel('Latitude');
    % draw the colorbar
    cbar = colorbar; 
    clim("manual");
    clim([min_dbh max_dbh]); % * colorbar range
    colormap(map);
    set(gca,'ColorScale','linear')
    cbar.Label.String = "Variation (nT)";
    cbar.Label.FontSize = 12;

    % draw the title
    minute_time = t+TIME-1;
    hour = num2str(fix(minute_time/60));
    if strlength(hour) == 1
        hour = ['0' hour];
    end
    minute = num2str(mod(minute_time, 60));
    if strlength(minute) == 1
        minute = ['0' minute];
    end

    str_title=['UTC ' hour ':' minute];
    title(str_title);
    annotation('textbox',...
        [0.82 0.066 0.077 0.052],... % * position of the text box
        'String',{'nT'},...
        'FontSize',12,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'LineStyle','none');

    % draw the axes
    xlim([long_range(1) long_range(2)-1]); % * longitude range
    ylim([lat_range(1) lat_range(2)-1]); % * lsatitude range
    % set the figure position
    set(gcf,'position',fig_position);
    % save the figure
    saveas(gcf,['figures\minute ',num2str(minute_time),'.png'], 'png');
end