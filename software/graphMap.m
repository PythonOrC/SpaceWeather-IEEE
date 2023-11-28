% This script generates a series of figures of the magnetic field variation
% of the Earth's surface using the data from the SuperMAG observatory
% network. The figures are generated in the figures folder in the current
% directory. The figures are generated in the order of the time steps in
% the downloaded file. The figures are named in the format of
% "yyyy-MM-dd HH-mm-ss.png" where yyyy-MM-dd is the date and HH-mm-ss is
% the time of the figure.
%
clear
%===================MUST CONFIGURE===================
OBSERVATORY_FILE = "data/sample/20031029-00-07-supermag.csv";   % path to the observatory file downloaded from supermag
%====================================================
%================OPTIONAL CONGURATION================
time_range = [];                % override time range of the generation in ISO 8601 format ("YYYY-MM-DDThh:mm:ss" e.g."2003-10-29T05:00:00") [start end]
                                % leave empty or undefined to use the time range of the downloaded file
plot_type = "absolute";         % type of plot, "difference" = difference from the previous time step i.e. time derivative of dbh, "absolute" = absolute value
                                % leave empty or undefined to use the default value of "absolute"
lat_range = [-90 90];           % latitude range of the display area in degrees
long_range = [-180 180];        % longitude range of the display area in degrees
fig_position = [10 10 600 400]; % position of the figure window in pixels [left bottom width height]
chunk_size = 10;                % size of the color chunks of magnetic latitude (10 = alternate color every 10 degrees)
preprocess_threshold = 0.1;     % remove stations with continuous missing data of length greater than this value (0.1 = 10%)
cbar_coverage = [0.5 99.5];     % colorbar coverage in percentile, [0.5 99.5] means 0.5% to 99.5% percentile, range = [0,100]
SHAPE_FILE = 'landareas.shp';   % load the shape file for the map
%====================================================

% check if the files exists
if ~isfile(OBSERVATORY_FILE)
    error("OBSERVATORY_FILE does not exist");
end
if ~isfile(SHAPE_FILE)
    error("SHAPE_FILE does not exist");
end

% declare time_range if not defined already
if ~exist('time_range', 'var') || isempty(time_range) 
    time_range = [];
end

% load the shape file
s = shaperead(SHAPE_FILE);

% preprocess the downloaded csv to remove stations that are too unreliable
clc
processed_file_path = preprocess(OBSERVATORY_FILE, time_range, preprocess_threshold);
raw = readtable(processed_file_path, "Delimiter",",", "DatetimeType","datetime");

% get relevant data from the raw dataset
[Stations,IA,IC] = unique(raw.IAGA, 'stable');
mlt_all = raw.MLT;
maglat_all = raw.MAGLAT;
datetime_all = unique(raw.Date_UTC, 'stable');

% get the latitude and longitude of each station
lat = raw.GEOLAT(1:length(Stations), 1);
long = raw.GEOLON(1:length(Stations), 1);
for i = 1:length(long)
    if long(i) > 180
        long(i) = long(i)-360;
    end
end

% determine the plot type
if ~exist('plot_type', 'var') || isempty(plot_type) 
    plot_type = "absolute";
end

if plot_type == "difference"
    calc_dbh = @getdbh_dt;
elseif plot_type == "absolute"
    calc_dbh = @getdbh;
else
    error("Invalid plot type");
end
% calculate change in dbh for each station
data_dbh = calc_dbh(raw, Stations);

% generate the location struct for each time step
LOC = getloc(Stations, chunk_size, mlt_all, maglat_all, lat, long);

% combine the data and the Stations together into a table
OBS = table(Stations, lat, long, data_dbh);
%resulting sample structure of all:
    % Stations    lat       long        data_dbh      
    % ________    _____    _______   _______________
    % {'BOU'}     40.14    -105.24   {1440×1 double}
    % {'BSL'}     30.35     -89.64   {1440×1 double}
    % {'FRD'}      38.2     -77.37   {1440×1 double}
    % {'FRN'}     37.09    -119.72   {1440×1 double}
    % {'NEW'}     48.27    -117.12   {1440×1 double}

%combine all dbh values into a 2d array
dat_dbh = [];
for i = 1:length(OBS.Stations)
    dat_dbh = [dat_dbh OBS(strcmp(OBS.Stations, OBS.Stations(i)), : ).data_dbh{1}];
end

%get the upper and lower bounds of the data
min_dbh = prctile(dat_dbh, cbar_coverage(1), 'all');
max_dbh = prctile(dat_dbh, cbar_coverage(2), 'all');

%Use meshgrid to create a set of 2-D grid points in the longitude-latitude plane and then use griddata to interpolate the corresponding depth at those points:
[longi,lati] = meshgrid(long_range(1):0.5:long_range(2), lat_range(1):0.5:lat_range(2)); % * 0.5 is the resolution, longitude then latitude

% clear unnecessary variables
clearvars -except OBS LOC dat_dbh datetime_all longi lati fig_position s map min_dbh max_dbh long_range lat_range

% graph the data
for idx = 1:length(datetime_all)-1
    datetime_c = datetime_all(idx);% _c = current data for all stations
    fprintf("Generating %s (%d/%d %.2f%% complete)\n", string(datetime_c, 'yyyy-MM-dd HH:mm:ss'), idx, length(datetime_all), idx/length(datetime_all)*100); % status update
    dat_dbh_c = dat_dbh(idx,:); 

    % kriging interpolation
    v = variogram([OBS.long OBS.lat],dat_dbh_c');
    [~,~,~,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable');
    close;
    [OBSi,OBSVari] = kriging(vstruct,OBS.long',OBS.lat',dat_dbh_c,longi,lati);
    
    % draw the figure
    figure('Color','w', 'Position',[0 0 1280 720]);
    h=pcolor(longi,lati,OBSi); % draw the points
    hold on
    set(h,'EdgeColor','none'); 
        
    % draw the stations with MLT == 24
    for i = 1:length(LOC{2,idx})
        if ~isempty(LOC{2,idx}{i})
            if i/2 ~= floor(i/2)
                station_color = [0 0 0];
            else
                station_color = [1 1 1];
            end
            geoshow(LOC{2,idx}{i},'Marker','o',...
            'MarkerFaceColor',station_color,'MarkerEdgeColor','k', 'MarkerSize', 5);
        end
    end
    % draw the stations with MLT != 24
    for i = 1:length(LOC{1,idx})
        if ~isempty(LOC{1,idx}{i})
            geoshow(LOC{1,idx}{i},'Marker','d',...
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
    colormap(generateColormap([min_dbh max_dbh]));
    set(gca,'ColorScale','linear')
    cbar.Label.String = "Variation (nT)";
    cbar.Label.FontSize = 12;

    % draw the title
    title(string(datetime_c, 'yyyy-MM-dd HH:mm:ss'));

    % configure axes
    annotation('textbox',...     % draw the axes
        [0.82 0.066 0.077 0.052],... % position of the text box
        'String',{'nT'},...
        'FontSize',12,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'LineStyle','none');
    xlim([long_range(1) long_range(2)-1]); % set longitude range
    ylim([lat_range(1) lat_range(2)-1]); % set latitude range

    % configure fig position
    set(gcf,'position',fig_position);

    % save figure
    saveas(gcf,'figures\'+string(datetime_c, 'yyyy-MM-dd HH-mm-ss')+'.png');
end