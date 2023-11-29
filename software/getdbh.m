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
function data_dbh = getdbh(raw, Stations)
% declare variables
data_dbh = {};

% loop through all the stations
for i = 1:length(Stations)
    % raw datum refers to all the data from a single station
    raw_datum = raw(raw.IAGA == string(Stations(i)), :);
    % extract the needed datum from the raw datum
    datum_dbn = table2array(raw_datum(:,{'dbn_nez'}));
    datum_dbe = table2array(raw_datum(:,{'dbe_nez'}));

    %calculate dbh
    for j = 1:length(datum_dbn)
        dbh = sqrt(datum_dbn(j)^2 + datum_dbe(j)^2);
        % assign the dbh to the correct signage
        if datum_dbn(j) < 0
            dbh = -dbh;
        end
        datum_dbh(j) = dbh;
    end
    data_dbh = [data_dbh; datum_dbh']; % add the datum to the data cell array
end
end