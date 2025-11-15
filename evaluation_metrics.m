% optimize_station_placement.m - Main driver script for SMART_GRID project
clear; clc; close all;
% Load dataset
dataset = readtable('CityX_SmartGrid_Dataset.csv');
nSites = height(dataset);

% Demand model (calls demand_model.m)
% NOTE: You need to have a separate function named 'demand_model.m'
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
% NOTE: You need to have a separate function named 'fitness_fn.m'
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


%% --------------------------------------------------------
%  3. Reliability Metrics Calculation (SAIFI & SAIDI)
%  --------------------------------------------------------

fprintf('\n\n--- Evaluating Reliability Metrics for Chosen Sites ---\n');

% Step A: Extract Demand Data for Chosen Sites
selected_sessions_daily = siteDemand(chosenIdx); 
selected_sessions_annually = selected_sessions_daily * 365;
num_chosen = length(chosenIdx);

% -------------------------------------------------------------------------
% Step B: Placeholder Reliability Data (*** CRITICAL: REPLACE THESE ***)
% You MUST replace these arrays with the actual estimated annual failure 
% rate (lambda) and mean repair time (r) for the 8 sites chosen by the GA.
% This data should be available from the parameters used in your fitness_fn.
% -------------------------------------------------------------------------

% Annual Failure Rate (Lambda_i, failures/year) for the 8 chosen sites
% Ensure the length matches 'num_chosen' (which should be 8)
outage_rate_per_year = [0.4; 0.6; 0.5; 0.3; 0.7; 0.5; 0.4; 0.6]; % << REPLACE

% Mean Time to Repair (r_i, hours) for the 8 chosen sites
% Ensure the length matches 'num_chosen' (which should be 8)
repair_time_hours = [15; 18; 12; 20; 10; 15; 18; 12];           % << REPLACE


% Step C: Calculate Total Sessions Served
% Total sessions across ALL 100 potential sites served annually
total_sessions_daily = sum(siteDemand);
total_network_sessions_per_year = total_sessions_daily * 365;


% --- SAIFI Calculation ---
% Total number of interruptions experienced by ALL sessions in a year.
% SAIFI = Sum(Demand_i * Lambda_i) / Total_Network_Demand
total_interruptions = sum(selected_sessions_annually .* outage_rate_per_year);

SAIFI = total_interruptions / total_network_sessions_per_year;
fprintf('System Average Interruption Frequency Index (SAIFI): %.4f interruptions/session-year\n', SAIFI);


% --- SAIDI Calculation ---
% Total annual outage time (U_i) for each station: U_i = Lambda_i * r_i (hours/year)
annual_outage_time_hours = outage_rate_per_year .* repair_time_hours;

% Total duration of interruptions experienced by ALL sessions in a year (Hours * Sessions)
% SAIDI = Sum(Demand_i * Lambda_i * r_i) / Total_Network_Demand
total_interruption_duration_sessions = sum(selected_sessions_annually .* annual_outage_time_hours);

SAIDI = total_interruption_duration_sessions / total_network_sessions_per_year;
fprintf('System Average Interruption Duration Index (SAIDI): %.4f hours/session-year\n', SAIDI);


%% --------------------------------------------------------
%  4. Visualization and Saving
%  --------------------------------------------------------

% Save MATLAB data for auto-load plotting
save('matlab.mat', 'dataset', 'siteDemand', 'chosenSites', 'chosenIdx');

% Plot results
try
    % NOTE: You need to have a separate function named 'plot_results.m'
    plot_results(dataset, chosenSites, siteDemand);
    drawnow;
catch ME
    warning('plot_results failed: %s\nTrying auto mode...', ME.message);
    plot_results(); % auto-load mode
end