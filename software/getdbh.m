function data_dbh = getdbh(raw, Stations)

% declare variables
data_dbe = {};
data_dbn = {};
data_dbh = {};

% loop through all the stations
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
end