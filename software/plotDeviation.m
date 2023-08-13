clear;
STORM = 1;
time_interval = 52:202;


all_data ={};
station = 1:193;
if (STORM == 2)
    station = 1:188;
end
points = [];
idxes = [1 1 1];
divides = [15 45 inf];

for i = 1: length(station)
    data = load(['D:\Github Repository\SpaceWeather-IEEE\software\OBS_Storm' num2str(STORM) '\OBS_' num2str(station(i)) '.mat']);
    all_data = [all_data;data.OBS(station(i),:)];
end
for i = 1: length(station)
    all_data.data_dbh{i} = all_data.data_dbh{i}(time_interval);
    all_data.sim_dbh{i} = all_data.sim_dbh{i}(time_interval);

    all_data.diff_dbh{i} = all_data.data_dbh{i} - all_data.sim_dbh{i};
    all_data.r_diff_dbh{i} = all_data.data_dbh{i} - all_data.sim_dbh{i};
    for j = 1:length(all_data.data_dbh{i})
        all_data.r_diff_dbh{i}(j) = abs(all_data.r_diff_dbh{i}(j)/all_data.data_dbh{i}(j));
    end
    all_data.MAE(i) = sum(abs(all_data.diff_dbh{i}))/length(all_data.diff_dbh{i});
    all_data.RMSE(i) = rmse(all_data.sim_dbh{i}, all_data.data_dbh{i});
    all_data.MEDIAN(i) = median(abs(all_data.data_dbh{i}));
    all_data.MEAN(i) = mean(abs(all_data.data_dbh{i}));
    all_data.MAX(i) = max(abs(all_data.data_dbh{i}));
    all_data.RRMSE_MEAN(i) = all_data.RMSE(i)/all_data.MEAN(i) * 100;
    all_data.RRMSE_MEDIAN(i) = all_data.RMSE(i)/all_data.MEDIAN(i) * 100;
    all_data.RRMSE_MAX(i) = all_data.RMSE(i)/all_data.MAX(i) * 100;
    all_data.RMAE_MEAN(i) = all_data.MAE(i)/all_data.MEAN(i) * 100;
    all_data.RMAE_MEDIAN(i) = all_data.MAE(i)/all_data.MEDIAN(i) * 100;
    all_data.RMAE_MAX(i) = all_data.MAE(i)/all_data.MAX(i) * 100;
    for j = 1:length(divides)
        if (all_data.RMAE_MAX(i) <= divides(j))
            points{j}(idxes(j)).Geometry = 'Point';
            points{j}(idxes(j)).Lat = all_data.lat(i);
            points{j}(idxes(j)).Lon = all_data.long(i);
            idxes(j) = idxes(j) + 1;
            break;
        end
    end
end


s = shaperead('landareas.shp');
figure('Color','w', 'Position',[0 0 1280 720]);
xlim([-180 180]);
ylim([-90 90]);
yticks(-90:30:90);
xticks(-180:30:180);
hold on
    
c = {[0 1 0]; [1 1 0]; [1 0 0]};
% draw the stations diffferently
for i = 1:length(points)
    geoshow(points{i},'Marker','o','MarkerFaceColor',c{i},'MarkerEdgeColor','k', 'MarkerSize', 8);
end


mapshow(s,'FaceAlpha', 0);

xlabel('Longitude'), ylabel('Latitude');

figure;
disp_stations = [150 66 109];
set(gcf,'Position',[1921 -850 600 1080])
for i = 1:3
    subplot(3,1,i);
    hold on;
    errorbar(all_data.data_dbh{disp_stations(i)},all_data.diff_dbh{disp_stations(i)},'LineStyle', 'none');
    plot(all_data.data_dbh{disp_stations(i)},'color', 'r');
    ylim([-1350 1100]);
    ylabel([all_data.Stations(disp_stations(i)) "dBh (nT)"]);
    xlabel("Time (UTC)");
    xticks(1:30:151);
    xticklabels(["6:00" "6:30" "7:00" "7:30" "8:00" "8:30"]);
    set(gca,"XMinorTick", "on", "YMinorTick", "on");
end

%%two in ocean, two in north america, one YKC, one in europe

% adjust error bar as needed

%PPT, PAF, VIC, FRD, YKC, NGK
%150, 151, 186, 66, 193, 132;
