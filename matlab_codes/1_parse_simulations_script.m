% load('simulation_p10_full.mat') % load simulation output
% load('simulation_p15_full.mat') % load simulation output
load('simulation_p20_full.mat') % load simulation output

%% parse simulation results into cell array
nSets = 30; % number of settings (unique parameters)
nTs = 3; % number of time lengths per setting
nDatasets = 5; % number of datasetes per time length
nMethods = 4; % number of methods evaluated

resultCell = cell(nSets*nTs*nDatasets, 20); % storage for output cell array
resultCellColNames = ["settings", ... % 1
    "snr", ... % 2
    "parameter.ID", ... % 3
    "T", ... % 4
    "fp", ... % 5
    "fn", ... % 6
    "mse", ... % 7
    "compTime", ... % 8
    "A", ... % 9
    "nu", ... % 10
    "A.Hat.Method1", ... % 11
    "A.Hat.Method2", ... % 12
    "A.Hat.Method3", ... % 13
    "A.Hat.Method4", ... % 14
    "nu.Hat.Method1", ... % 15
    "nu.Hat.Method2", ... % 16
    "nu.Hat.Method3", ... % 17
    "nu.Hat.Method4", ... % 18
    "converged", ... % 19
    "rng"]; % 20

rowNum = 1; % initialize row count
for setNum = 1:nSets
    for tNum = 1:nTs
        for dataNum = 1:nDatasets
            
            resultCell{rowNum, 1} = outMain(setNum).settings;
            resultCell{rowNum, 2} = outMain(setNum).simulations(tNum).data{1}(dataNum);
            resultCell{rowNum, 3} = setNum;
            resultCell{rowNum, 4} = outMain(setNum).simulations(tNum).T;
            resultCell{rowNum, 5} = outMain(setNum).simulations(tNum).evals(dataNum, :, 2);
            resultCell{rowNum, 6} = outMain(setNum).simulations(tNum).evals(dataNum, :, 3);
            resultCell{rowNum, 7} = outMain(setNum).simulations(tNum).evals(dataNum, :, 4);
            resultCell{rowNum, 8} = outMain(setNum).simulations(tNum).checks{1}(dataNum, :);
            resultCell{rowNum, 9} = outMain(setNum).parameters{1};
            resultCell{rowNum, 10} = outMain(setNum).parameters{2};
            resultCell{rowNum, 11} = outMain(setNum).simulations(tNum).estimates{1}(:, :, 1, dataNum);
            resultCell{rowNum, 12} = outMain(setNum).simulations(tNum).estimates{1}(:, :, 2, dataNum);
            resultCell{rowNum, 13} = outMain(setNum).simulations(tNum).estimates{1}(:, :, 3, dataNum);
            resultCell{rowNum, 14} = outMain(setNum).simulations(tNum).estimates{1}(:, :, 4, dataNum);
            resultCell{rowNum, 15} = outMain(setNum).simulations(tNum).estimates{2}(:, :, 1, dataNum);
            resultCell{rowNum, 16} = outMain(setNum).simulations(tNum).estimates{2}(:, :, 2, dataNum);
            resultCell{rowNum, 17} = outMain(setNum).simulations(tNum).estimates{2}(:, :, 3, dataNum);
            resultCell{rowNum, 18} = outMain(setNum).simulations(tNum).estimates{2}(:, :, 4, dataNum);
            resultCell{rowNum, 19} = outMain(setNum).simulations(tNum).checks{2}(dataNum, :);
            resultCell{rowNum, 20} = outMain(setNum).simulations(tNum).data{2}(dataNum).rng;
            
            rowNum = rowNum + 1;
        end
    end
end

%% create table for tidy output of scalar quantities
resultTblColNames = ["settings", ... %
    "snr", ... % 2
    "parameter.ID", ... % 3
    "T", ... % 4
    "fp", ... % 5
    "fn", ... % 6
    "mse", ... % 7
    "compTime", ... % 8
    "converged"]; % 9
resultTbl = cell2table(resultCell(:, [1:8, 19]), ...
    'VariableNames', resultTblColNames);

% writetable(resultTbl, 'sim_p10_resultTbl.csv')
% writetable(resultTbl, 'sim_p15_resultTbl.csv')
writetable(resultTbl, 'sim_p20_resultTbl.csv')

%% create for output of array quantities

% store column names
writetable(cell2table(cellstr(resultCellColNames(9:18)'), ...
    'VariableNames', "column.name"), ...
    'resultCellColNames.csv', ...
    'QuoteStrings', true)

resultAry = resultCell(:, 9:18);
% save('sim_p10_resultAry.mat', 'resultAry')
% save('sim_p15_resultAry.mat', 'resultAry')
save('sim_p20_resultAry.mat', 'resultAry')






