%% ------------------------------
%% Load GA results
%% ------------------------------
if exist('matlab.mat','file')
    load('matlab.mat');  % loads chosenIdx, chosenSites, dataset, siteDemand
else
    error('matlab.mat file not found. Run optimize_station_placement.m first.');
end

%% ------------------------------
%% Display indices of chosen sites
%% ------------------------------
disp('Indices of chosen EV stations in the dataset:');
disp(chosenIdx');

%% ------------------------------
%% Display full table of chosen sites
%% ------------------------------
disp('Full table of chosen EV stations:');
disp(chosenSites);

%% ------------------------------
%% Display chosen stations neatly with coordinates & demand
%% ------------------------------
fprintf('\n✅ Chosen EV Stations (Site_ID, Coordinates, EVs Needed):\n');
for i = 1:height(chosenSites)
    
    % Check if latitude/longitude exist
    if all(ismember({'Latitude','Longitude'}, chosenSites.Properties.VariableNames))
        fprintf('Station %d → Site_ID: %s, Lat: %.4f, Lon: %.4f, EVs Needed: %d\n', ...
            i, chosenSites.Site_ID{i}, chosenSites.Latitude(i), chosenSites.Longitude(i), chosenSites.EVs_Need_Station(i));
        
    % If X/Y coordinates exist
    elseif all(ismember({'X','Y'}, chosenSites.Properties.VariableNames))
        fprintf('Station %d → Site_ID: %s, X: %.2f, Y: %.2f, EVs Needed: %d\n', ...
            i, chosenSites.Site_ID{i}, chosenSites.X(i), chosenSites.Y(i), chosenSites.EVs_Need_Station(i));
    
    % If no coordinate info, only display Site_ID and EV demand
    else
        fprintf('Station %d → Site_ID: %s, EVs Needed: %d\n', ...
            i, chosenSites.Site_ID{i}, chosenSites.EVs_Need_Station(i));
    end
end
