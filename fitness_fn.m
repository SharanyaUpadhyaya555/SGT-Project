function cost = fitness_fn(x, dataset, siteDemand_kwh, Station_Capacity_EV_per_day)
% fitness_fn - simple fitness: aim to minimize number of stations + unmet demand penalty
% x is binary vector selecting stations (1=installed)
% station capacity is given in sessions/day (approx). siteDemand_kwh is energy; convert to sessions.
avg_kwh = 6; % average kWh per session
siteSessions = round(siteDemand_kwh ./ avg_kwh);

x = round(x(:))'; % ensure row binary
nStations = sum(x);
if nStations == 0
    % heavy penalty for no stations
    cost = 1e6 + sum(siteSessions);
    return;
end

% For each site, assume it is served if there is a station at that site (simple model)
servedSessions = x .* siteSessions;

% Unmet sessions = total sessions - sum(servedSessions, but station capacity matters)
unmet = max(0, sum(siteSessions) - nStations * Station_Capacity_EV_per_day);

% cost = number of stations + penalty_factor * unmet sessions
penalty_factor = 50;
cost = nStations + penalty_factor * unmet;
end
