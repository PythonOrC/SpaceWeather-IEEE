% a matlab function that reads in a csv file, the start time, and the duration
% and truncates the data to the specified time range
% remove the stations with too many missing values
% interpolates the missing values
% and saves the data to a new csv file
% 
% preprocess("20231029-00-07-supermag.csv",309,240)
% 
function new_file_name = preprocess(file_name, start_time, duration)

raw = readtable(file_name, "Delimiter",",", "DatetimeType","datetime");
stations_length = length(unique(raw.IAGA));
%extract data from table within the time range
% take the start_timeth row and the next duration rows

raw = raw(start_time*stations_length+1:(start_time+duration+1)*stations_length, :);

%remove the stations with 20 or more consecutive missing values in the dbn and dbe columns
% create a 3xn table that correlates missing dbn values and dbe to the station name
misses = table('Size',[0 3],'VariableTypes', ["string","double", "double"],'VariableNames', ["IAGA", "dbn", "dbe"]);
bad_stations = [];
for i = 1:height(raw)
    if isnan(raw.dbn_nez(i))
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbn(misses.IAGA == raw.IAGA{i}) = misses.dbn(misses.IAGA == raw.IAGA{i}) + 1;
            if misses.dbe(misses.IAGA == raw.IAGA{i}) >= 20 && ~any(strcmp(bad_stations,raw.IAGA{i}))
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

    if isnan(raw.dbe_nez(i))
        if ismember(raw.IAGA{i}, misses.IAGA)
            misses.dbe(misses.IAGA == raw.IAGA{i}) = misses.dbe(misses.IAGA == raw.IAGA{i}) + 1;
            if misses.dbe(misses.IAGA == raw.IAGA{i}) >= 20 && ~any(strcmp(bad_stations, raw.IAGA{i}))
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

% remove the stations with 
raw = raw(~ismember(raw.IAGA, bad_stations), :);

% interpolate the missing values
raw.dbn_nez = fillmissing(raw.dbn_nez, 'linear');
raw.dbe_nez = fillmissing(raw.dbe_nez, 'linear');

file = split(string(file_name), ".");
% save the data to a new csv file including the start time and duration
new_file_name = "preprocessed " + file(1) + " (start " + start_time + ", duration " + duration + ")."+file(2);
writetable(raw, new_file_name, "Delimiter",",");
end
