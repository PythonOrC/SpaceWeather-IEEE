% a matlab function that reads in a csv file, the start time, and the duration
% and truncates the data to the specified time range
% remove the stations with too many missing values
% interpolates the missing values
% and saves the data to a new csv file
%
% example:
% preprocess("20231029-00-07-supermag.csv",["2003-10-29T05:09:00" "2003-10-29T09:09:00"], 0.1)
%
function new_file_name = preprocess(file_name, time_range, threshold)
raw = readtable(file_name, "Delimiter",",", "DatetimeType","datetime");
stations_length = length(unique(raw.IAGA));

% determine the time resolution (minutes or seconds)
if raw.Extent == 60
    dur = @minutes; % minutes
else
    dur = @seconds; % seconds
end

% determine the duration of the data
datetime_range = [datetime(time_range(1), 'Format', 'hh-mm-ss') datetime(time_range(2), 'Format', 'hh-mm-ss')];
time_duration = dur(duration(datetime_range(2)-datetime_range(1)));
% determine start & end index of the time range
start_idx = find(raw.Date_UTC == datetime(time_range(1)),1);
end_idx = find(raw.Date_UTC == datetime(time_range(2)),1, "last");

% extract data from table within the time range
% take rows from start_idx to end_idx
raw = raw(start_idx:end_idx, :);

%remove the stations with `threshold` percent or more consecutive missing values in the dbn and dbe columns
% create a 3xn table that correlates missing dbn values and dbe to the station name
misses = table('Size',[0 3],'VariableTypes', ["string","double", "double"],'VariableNames', ["IAGA", "dbn", "dbe"]);
bad_stations = [];
for i = 1:height(raw)
    % check for continuous missing dbn values
    if isnan(raw.dbn_nez(i))
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbn(misses.IAGA == raw.IAGA{i}) = misses.dbn(misses.IAGA == raw.IAGA{i}) + 1;
            if misses.dbe(misses.IAGA == raw.IAGA{i}) >= threshold*time_duration && ~any(strcmp(bad_stations,raw.IAGA{i}))
                bad_stations = [bad_stations; raw.IAGA(i)];
            end
        else
            misses = [misses; [raw.IAGA(i), 1, 0]];
        end
    else
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbn(misses.IAGA == raw.IAGA{i}) = 0;
        end
    end
    % check for continuous missing dbe values
    if isnan(raw.dbe_nez(i))
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbe(misses.IAGA == raw.IAGA{i}) = misses.dbe(misses.IAGA == raw.IAGA{i}) + 1;
            if misses.dbe(misses.IAGA == raw.IAGA{i}) >= threshold*time_duration && ~any(strcmp(bad_stations, raw.IAGA{i}))
                bad_stations = [bad_stations; raw.IAGA(i)];
            end
        else
            misses = [misses; [raw.IAGA(i), 0, 1]];
        end
    else
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbe(misses.IAGA == raw.IAGA{i}) = 0;
        end
    end
end

% remove the stations with to many missing values
raw = raw(~ismember(raw.IAGA, bad_stations), :);

% interpolate the missing values for the rest of the stations
raw.dbn_nez = fillmissing(raw.dbn_nez, 'linear');
raw.dbe_nez = fillmissing(raw.dbe_nez, 'linear');

file = split(string(file_name), ".");
% save the data to a new csv file including the start time and duration
new_file_name = file(1) + " preprocessed (start " + string(datetime_range(1)) + " end " + string(datetime_range(2))+")."+file(2);
writetable(raw, new_file_name, "Delimiter",",");
end
