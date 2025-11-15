function plot_results(dataset, chosenSites, siteDemand)
% plot_results - Visualize EV demand and reliability-centric station placement
%
% Shows 4 panels:
%  (1) Demand bar chart (highlighting chosen sites)
%  (2) Geographic scatter of sites (blue = all, red = chosen)
%  (3) Histogram of site demand
%  (4) Cumulative demand coverage

    % ---------------------------
    % Data auto-loading (if args missing)
    % ---------------------------
    if nargin < 3
        if exist('matlab.mat','file')
            S = load('matlab.mat');
            dataset = S.dataset;
            chosenSites = S.chosenSites;
            siteDemand = S.siteDemand;
        else
            dataset = readtable('CityX_SmartGrid_Dataset.csv');
            chosenSites = readtable('Chosen_EV_Stations.csv');
            siteDemand = dataset.EVs_Need_Station;
        end
    end

    % Find indices of chosen sites
    chosenIdx = find(ismember(dataset.Site_ID, chosenSites.Site_ID));

    % Create figure
    figure('Name','EV Demand and Station Placement','NumberTitle','off','Position',[100 100 1300 750]);

    % ---------------------------
    % (1) Demand bar plot
    % ---------------------------
    subplot(2,2,1);
    bar(siteDemand, 'FaceColor', [0.3 0.6 1]);
    hold on;
    scatter(chosenIdx, siteDemand(chosenIdx), 80, 'r', 'filled');
    xlabel('Site Index'); ylabel('EV sessions/day');
    title('EV Charging Demand (Red = Selected Reliable Stations)');
    legend('Demand','Chosen Sites');
    grid on; hold off;

    % ---------------------------
    % (2) Geographic or scatter map
    % ---------------------------
    subplot(2,2,2);
    if all(ismember({'Latitude','Longitude'}, dataset.Properties.VariableNames))
        try
            % Try geographic map
            geoscatter(dataset.Latitude, dataset.Longitude, 30, 'b', 'filled', 'MarkerFaceAlpha',0.4);
            hold on;
            geoscatter(chosenSites.Latitude, chosenSites.Longitude, 60, 'r', 'filled', 'MarkerEdgeColor','k');
            geobasemap('streets');
            title('Reliability-Centric EV Station Placement (on map)');
            
            % Skip xlabel/ylabel for geographic axes
            ax = gca;
            if ~isa(ax, 'matlab.graphics.axis.GeographicAxes')
                xlabel('Longitude'); ylabel('Latitude');
                grid on;
            else
                grid off; % maps already show coordinates
            end
            legend('All Sites','Selected Reliable Sites');
            hold off;
        catch
            % Fallback to normal scatter if geoscatter fails
            scatter(dataset.Longitude, dataset.Latitude, 40, 'b', 'filled');
            hold on;
            scatter(chosenSites.Longitude, chosenSites.Latitude, 80, 'r', 'filled', 'MarkerEdgeColor','k');
            xlabel('Longitude'); ylabel('Latitude');
            title('Site Locations (Blue = All, Red = Selected)');
            legend('All Sites','Selected Reliable Sites');
            grid on; hold off;
        end
    else
        % Fallback to coordinate-only plot (no map)
        scatter(dataset.X, dataset.Y, 40, 'b', 'filled');
        hold on;
        scatter(chosenSites.X, chosenSites.Y, 80, 'r', 'filled', 'MarkerEdgeColor','k');
        xlabel('X'); ylabel('Y');
        title('Site Grid (Blue = All, Red = Selected)');
        legend('All Sites','Selected Reliable Sites');
        grid on; hold off;
    end

    % ---------------------------
    % (3) Demand distribution histogram
    % ---------------------------
    subplot(2,2,3);
    histogram(siteDemand, 12, 'FaceColor',[0.4 0.7 1]);
    xlabel('Sessions/day'); ylabel('Number of Sites');
    title('Distribution of Daily EV Charging Demand');
    grid on;

    % ---------------------------
    % (4) Cumulative demand coverage
    % ---------------------------
    subplot(2,2,4);
    [sortedDemand, idx] = sort(siteDemand, 'descend');
    cumulative = cumsum(sortedDemand);
    plot(cumulative, '-o', 'LineWidth',1.5);
    hold on;
    chosen_sorted_pos = find(ismember(idx, chosenIdx));
    if ~isempty(chosen_sorted_pos)
        scatter(chosen_sorted_pos, cumulative(chosen_sorted_pos), 80, 'r', 'filled');
    end
    xlabel('Sites ranked by demand'); ylabel('Cumulative sessions/day');
    title('Cumulative Demand Coverage');
    legend('All Sites','Chosen Reliable Stations','Location','southeast');
    grid on; hold off;

    % ---------------------------
    % Save final visualization
    % ---------------------------
    saveas(gcf, 'EV_Reliability_Placement_Results.png');
    fprintf('✅ Visualization saved as EV_Reliability_Placement_Results.png\n');
end
