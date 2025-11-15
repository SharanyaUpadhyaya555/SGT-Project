SGT - Smart Grid Toolkit
Contents:
- CityX_SmartGrid_Dataset.csv : generated dataset for 100 sites
- optimize_station_placement.m : main driver (runs GA and saves results)
- plot_results.m : plotting utility (plots and saves figure)
- demand_model.m : basic demand model to compute site demand
- fitness_fn.m : simple GA fitness function (minimize stations + unmet demand)
- matlab.mat : (not included until run) saved workspace used by plot_results in auto mode

How to use:
1. Open MATLAB and set current folder to this directory.
2. Run: optimize_station_placement
   - GA requires Global Optimization Toolbox (ga). If not available, the script falls back to greedy selection.
3. After run, check:
   - Chosen_EV_Stations.csv
   - Summary_Report.txt
   - EV_Demand_and_Placement.png
