function [siteDemand_kwh, totalDemand_kwh] = demand_model(dataset)
% demand_model - estimate site-level charging sessions (or energy) demand
% Here we use dataset.EVs_Need_Station and dataset.Daily_Energy_kWh
% Output: siteDemand_kwh = daily energy demand (kWh) per site
%         totalDemand_kwh = total daily energy demand (kWh)

if any(strcmp('Daily_Energy_kWh', dataset.Properties.VariableNames))
    siteDemand_kwh = dataset.Daily_Energy_kWh;
else
    % fallback: estimate using EVs_Need_Station and average energy per session
    avg_kwh = 6; % average session energy
    if any(strcmp('EVs_Need_Station', dataset.Properties.VariableNames))
        siteDemand_kwh = dataset.EVs_Need_Station * avg_kwh;
    else
        siteDemand_kwh = zeros(height(dataset),1);
    end
end

totalDemand_kwh = sum(siteDemand_kwh);
% Convert to sessions/day if needed in caller (caller may divide by avg_kwh)
end
