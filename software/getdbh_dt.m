% This function extracts the dbh data from the raw data
% The dbh data is the horizontal component of the magnetic field
% The dbh data is calculated from the dbn and dbe data using the pythagorean theorem
% The dbh data is returned as a cell array
%
% Input:
%   raw: the raw data
%   Stations: the stations to extract the dbh data from
%
% Output:
%   data_dbh: the dbh data
%
function data_dbh_dt = getdbh_dt(raw, Stations)
% declare variables
data_dbh_dt = {};

% loop through all the stations
for i = 1:length(Stations)
    % raw datum refers to all the data from a single station
    raw_datum = raw(raw.IAGA == string(Stations(i)), :);
    % extract the needed datum from the raw datum
    datum_dbn = table2array(raw_datum(:,{'dbn_nez'}));
    datum_dbe = table2array(raw_datum(:,{'dbe_nez'}));
    datum_dbn_dt = diff(datum_dbn); % calculate the derivative of the dbn data
    datum_dbe_dt = diff(datum_dbe); % calculate the derivative of the dbe data

    %calculate dbh
    for j = 1:length(datum_dbn_dt)
        dbh_dt = sqrt(datum_dbn_dt(j)^2 + datum_dbe_dt(j)^2);
        % assign the dbh to the correct signage
        if datum_dbn_dt(j) < 0
            dbh_dt = -dbh_dt;
        end
        datum_dbh_dt(j) = dbh_dt;
    end
    data_dbh_dt = [data_dbh_dt; datum_dbh_dt']; % add the datum to the data cell array
end
end