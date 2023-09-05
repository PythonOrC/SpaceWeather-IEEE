DATA = 'dbn_nez';
SEG = 2;
MARGIN = 0;
MLT_MARGIN = 1;
MAGLAT_CHUNK_SIZE = 10;
% import the raw unprocessed data
if SEG == 1
    raw = readtable("HalloweenStorm-SuperMAG-0509.csv", "Delimiter",",", "DatetimeType","datetime");
    raw_ACE = readtable("ACE_0509_interp.csv");
    TIME = 309;
    DURATION = 240;

else
    TIME = 1044;
    DURATION = 420;
    raw = readtable("HalloweenStorm-SuperMAG-1724.csv", "Delimiter",",", "DatetimeType","datetime");
    raw_ACE = readtable("ACE_1724_interp.csv");
end

INTERVAL = TIME:TIME+DURATION-1;

% get the stations from the raw data
[Stations,IA,IC] = unique(raw.IAGA, 'stable');
mlt_all = raw.MLT;
maglat_all = raw.MAGLAT;
% get the latitude and longitude of each station
lat = raw.GEOLAT(1:length(Stations), 1);
long = raw.GEOLON(1:length(Stations), 1);
By = raw_ACE.By;
Bz = raw_ACE.Bz;


clear LOC;
% lat + long of stattions MLT != 12
LOC={};

for i = 1:length(raw.MLT)/length(Stations)
    % temp storage for MLT != 12
    loc_n = [];
    % temp storage for MLT == 12
    loc_m = [];
    % indexs
    loc_n_i = zeros(ceil(180/MAGLAT_CHUNK_SIZE)+1,1) + 1;
    loc_m_i = zeros(ceil(180/MAGLAT_CHUNK_SIZE)+1,1) + 1;
    % loop through each station individually
    % j = index of station
    for j = 1:length(Stations)
        mlt = mlt_all((i-1)*length(Stations)+j);
        maglat = maglat_all((i-1)*length(Stations)+j);
        % decide which maglat chunk the station is in
        maglat_chunk = floor(maglat/MAGLAT_CHUNK_SIZE) + ceil(floor(180/MAGLAT_CHUNK_SIZE)/2)+1;
        % append the station to the correct list
        if mlt <= 12+MLT_MARGIN && mlt >= 12-MLT_MARGIN
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Geometry = 'Point';
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Lat = lat(j);
            loc_m{maglat_chunk}(loc_m_i(maglat_chunk)).Lon = long(j);
            loc_m_i(maglat_chunk) = loc_m_i(maglat_chunk) + 1;
        else
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Geometry = 'Point';
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Lat = lat(j);
            loc_n{maglat_chunk}(loc_n_i(maglat_chunk)).Lon = long(j);
            loc_n_i(maglat_chunk) = loc_n_i(maglat_chunk) + 1;
        end
    end
    LOC{1,i} = loc_m;
    LOC{2,i} = loc_n;
end
% struct of LOC
%                  t=1            t=2            t=3            t=4            t=5            t=6            t=7        t=n 
% MLT == 12 -> {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    {1×16 cell}    ...
% MLT != 12 -> {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    {1×18 cell}    ...

% struct of one of the cell
%    -90           -89 ~ -80       -79 ~ -60               80 ~ 90
% {0×0 double}    {1×4 double}    {0×0 double}    ...    {1×5 double}
clear max;
clear min;
max_lat = 90;
min_lat = -90;
max_long = 180;
min_long = -180;

clear max;
clear min;
% extract the necessary data from the raw data
clear data;
data = {};
for i = 1:length(Stations)
    % raw datum refers to all the data from a single station
    raw_datum = raw(raw.IAGA == string(Stations(i)), :);
    % extract the needed datum from the raw datum
    % datum = table2array(raw_datum(INTERVAL,{DATA}));
    datum = table2array(raw_datum(:,{DATA}));
    %interpolate the Nan values
    datum = fillmissing(datum, 'linear');
    % add the datum to the data cell array
    data = [data; datum];
end

% combine the data and the Stations together
clear OBS;
OBS = table(Stations, data, lat, long);
%resulting sample structure of all:
    % Stations         data           lat      long  
    % ________    _______________    _____    _______
    % {'BOU'}     {1440×1 double}    40.14    -105.24
    % {'BSL'}     {1440×1 double}    30.35     -89.64
    % {'FRD'}     {1440×1 double}     38.2     -77.37
    % {'FRN'}     {1440×1 double}    37.09    -119.72
    % {'NEW'}     {1440×1 double}    48.27    -117.12

%combine all the values together
clear dat;
dat = [];
for i = 1:length(OBS.Stations)
    dat = [dat OBS(strcmp(OBS.Stations, OBS.Stations(i)), : ).data{1}];
end

%get the upper and lower bounds of the data
clear min;
clear max;

min = min(min(dat));
max = max(max(dat));
    %Use meshgrid to create a set of 2-D grid points in the longitude-latitude plane and then use griddata to interpolate the corresponding depth at those points:
[longi,lati] = meshgrid(min_long:1:max_long, min_lat:1:max_lat); % * 0.5 is the resolution, longitude then latitude
% graph the data
s = shaperead('landareas.shp');
for t = 1: length(OBS.data{1})
% for t = 1:1
    disp("Generating...");
    dat_c = dat(t,:);
    v = variogram([OBS.long OBS.lat],dat_c');
    [~,~,~,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable');
    close;
    [OBSi,OBSVari] = krigingtest(vstruct,OBS.long',OBS.lat',dat_c,longi,lati);
    
    
  figure('Color','w', 'Position',[0 0 1280 720]);

    h=pcolor(longi,lati,OBSi); % * draw the points
    hold on
    set(h,'EdgeColor','none'); 
        
    % mapshow(LOC{1,t},'Marker','o',...
    % 'MarkerFaceColor',[1 0.5 0],'MarkerEdgeColor','k');
    % mapshow(LOC{2,t},'Marker','o',...
    % 'MarkerFaceColor','b','MarkerEdgeColor','k');
    % display the stations
    for i = 1:length(LOC{2,t})
        if ~isempty(LOC{2,t}{i})
            if i/2 ~= floor(i/2)
                c = [0 0 0];
            else
                c = [1 1 1];
            end
            mapshow(LOC{2,t}{i},'Marker','o',...
            'MarkerFaceColor',c,'MarkerEdgeColor','k');
        end
    end

    for i = 1:length(LOC{1,t})
        if ~isempty(LOC{1,t}{i})
            if i/2 ~= floor(i/2)
                c = [1 0 1];
            else
                c = [1 0 1];
            end
            mapshow(LOC{1,t}{i},'Marker','d',...
            'MarkerFaceColor',c,'MarkerEdgeColor','k');
        end
    end
    mapshow(s,'FaceAlpha', 0);
    
    % colormap gray;
    xlabel('Longitude'), ylabel('Latitude'), colorbar; 
    clim([min max]) % * colorbar range
    if t+TIME-1 <= 1440
        date_label =  '20031029 minute ';
        minute_time = t+TIME-1;
    else
        date_label =  '20031030 minute ';
        minute_time = t+TIME-1-1440;
    end
    hour = num2str(fix(minute_time/60));
    if strlength(hour) == 1
        hour = ['0' hour];
    end

    minute = num2str(mod(minute_time, 60));
    if strlength(minute) == 1
        minute = ['0' minute];
    end
    str_title=['Global Map of Magnetic Field Variation North Component dBn at UTC ' hour ':' minute];
    title(str_title);
    annotation('textbox',...
        [0.87 0.905 0.077 0.052],... % * position of the text box
        'String',{'nT'},...
        'FontSize',12,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'LineStyle','none');
    xlim([min_long max_long-1]); % * longitude range
    ylim([min_lat max_lat-1]); % * latitude range
    
    saveas(gcf,['D:\Github Repository\SpaceWeather\matlab\examples\draftFigure\',date_label,num2str(minute_time),'.png'], 'png')
end