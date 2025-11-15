% optimize_station_placement.m - Main driver script for SMART_GRID project
clear; clc; close all;

% Load dataset
dataset = readtable('CityX_SmartGrid_Dataset.csv');
nSites = height(dataset);

% Demand model (calls demand_model.m)
[siteDemand, totalDemand] = demand_model(dataset);

% Station capacity & required stations (tunable)
Station_Capacity_kWh_per_day = 1500;  % kWh/day per charging station (example)
Average_Session_kWh = 6;              % average kWh per charging session (for capacity->sessions conversion)
Station_Capacity_EV_per_day = floor(Station_Capacity_kWh_per_day / Average_Session_kWh);

% --------------------------------------------------------
% Force selection of exactly 8 stations (manual override)
% --------------------------------------------------------
Stations_Needed = 8;   % ✅ FIXED NUMBER OF SITES TO SELECT

fprintf('Estimated total daily charging demand (kWh): %.1f kWh/day\n', sum(siteDemand).*1.0);
fprintf('Assumed station capacity (sessions/day): %d EV sessions/day\n', Station_Capacity_EV_per_day);
fprintf('==> Stations to select (fixed): %d\n\n', Stations_Needed);

% GA setup
nvars = nSites;
IntCon = 1:nvars;
LB = zeros(1, nvars);
UB = ones(1, nvars);

% -----------------------------
% Linear equality constraint
% -----------------------------
% Enforce exactly 8 selected stations
Aeq = ones(1, nvars);
beq = Stations_Needed;

% Objective wrapper (GA minimizes)
objFn = @(x) fitness_fn(round(x), dataset, siteDemand, Station_Capacity_EV_per_day);

options = optimoptions('ga', ...
    'PopulationSize', 120, ...
    'MaxGenerations', 120, ...
    'UseParallel', false, ...
    'Display', 'iter');

% Run GA
try
    [xBest, fval] = ga(objFn, nvars, [], [], Aeq, beq, LB, UB, [], IntCon, options);
    xBest = round(xBest);
catch ME
    warning('GA failed or not available: %s\nFalling back to greedy selection.', ME.message);
    xBest = zeros(1,nSites);
end

chosenIdx = find(xBest == 1);
chosenSites = dataset(chosenIdx, :);

% Fallback in case GA picks none
if isempty(chosenSites)
    warning('No sites selected by GA. Selecting top-demand sites manually...');
    [~, idx] = maxk(siteDemand, Stations_Needed);
    chosenSites = dataset(idx, :);
    chosenIdx = idx;
end

% Save results
writetable(chosenSites, 'Chosen_EV_Stations.csv');
fprintf('\n✅ Selected %d stations.\n', height(chosenSites));

% Save MATLAB data for auto-load plotting
save('matlab.mat', 'dataset', 'siteDemand', 'chosenSites', 'chosenIdx');

% Plot results
try
    plot_results(dataset, chosenSites, siteDemand);
    drawnow;
catch ME
    warning('plot_results failed: %s\nTrying auto mode...', ME.message);
    plot_results(); % auto-load mode
end
