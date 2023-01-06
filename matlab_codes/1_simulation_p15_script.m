rng(33020)
parpool()

%% simulation settings

% main combinations
% pVec = [10, 20, 40]; % process dimension
pctNzVec = [0.01, 0.02, 0.05]; % parameter sparsity

% inner combinations
nParReps = 10; % number of parameters to generate per main combination
tVec = [500 1000 2000]; % realization lengths
nDatasets = 5; % number of datasets to generate per realization length

% fixed parameter generation settings across all combinations
tht = 1; % maximum parameter magnitude
positive_prob = 0.3; % approximate proportion of positive entries in A
nsim = 10; % number of realizations from which to estimate SNR
Tsim = 100000; % length of each realization used to estimate SNR
snr_min = 0.5;
snr_max = 1.5;

%% settings for the lasso
nLam = 80; % regularization path length
lambda_path = logspace(4, 1.5, nLam); % regularization path
alpha = 0.99; % elastic net mixing parameter
maxIter = 200; % maximum number of cycles through coordinates in coordinate descent
convCrit = 10^(-6); % convergence criterion (normalized L1 distance between iterations)
dist = 1; % response distribution flag (1 for poisson, 2 for gaussian)

%% method settings
nSamp = 10; % number of subsamples to use in cross validation
subSampMethod = 1; % subsampling method (1: blockwise holdout)
nSampSuppEst = 8; % number of subsamples to use in support stabilization
threshParVec = 0.5:0.05:1; % range of threshold parameters
nSampThresh = 8; % number of subsamples to use in threshold tuning
fixSupportEstimates = 0;
fixSupportEstimates_inner = 0;
fixSupportEstimates_outer = 0;

%% storage for outputs
outMain = struct(...
    'settings', {}, ...
    'parameters', {}, ...
    'simulations', {} ...
    );
outerSetNum = 1;


%% simulation

% replication at main combination level
for parRepNum = 1:nParReps
    
    % fix main combination
    p = 15;
    for pctNz = pctNzVec
        
        % print monitor output header
        fprintf('\n\n rep %d sparsity %d \n\n', ...
            parRepNum, 100*pctNz);
  
        
        % generate parameters
        nu_entry = fix_nu(p, pctNz); % intercept entry
        nu = ones(p, 1)*nu_entry; % intercept vector
        A = A_search(nu, snr_min, snr_max, pctNz, positive_prob, tht, Tsim, nsim); % A matrix
                        
        % full information capture
        outMain(outerSetNum).settings = [p, pctNz];
        outMain(outerSetNum).parameters = {A, nu};
        outMain(outerSetNum).simulations = struct(...
            'T', {}, ...
            'data', {}, ...
            'estimates', {}, ...
            'evals', {}, ...
            'checks', {});
        
        % create storage for rolling output
        outRolling = struct(...
            'settings', {}, ...
            'parameters', {}, ...
            'data', {}, ...
            'estimates', {}, ...
            'evals', {}, ...
            'checks', {});
        
        % inner increment (tracks T)
        tNum = 1;
            
        % fix realization length
        for T = tVec
            
            % create storage for outputs at datset level
            evalErrors = zeros(nDatasets, 4, 4); % count of position errors, tp/fp, mse
            snr = zeros(nDatasets, 1); % snr on simulated dataset
            compTimes = zeros(nDatasets, 4); % computation times per method
            convChecks = zeros(nDatasets, 4); % convergence checks per method
            A_hats = zeros(p, p, 4, nDatasets); % estimated parameter matrices
            nu_hats = zeros(p, 1, 4, nDatasets); % estimated intercepts
            dataRng = struct('rng', []); % rng state captures (for reproducing data)
            
            % replication at dataset level
            for dataNum = 1:nDatasets
                
                % capture rng state
                dataRng(dataNum).rng = rng;
                
                % generate data
                [data, snr(dataNum)] = sim_data_snr(nu, A, T, snr_min, snr_max);
                
                % estimate for case 1
                suppEstOpt = 1;
                [A_hats(:, :, 1, dataNum), nu_hats(:, :, 1, dataNum), convChecks(dataNum, 1), compTimes(dataNum, 1)] = ...
                    method1(...
                    data, ... % data (T x p) matrix (descending time order)
                    lambda_path, ... % regularization path
                    nSamp, ... % number of subsamples to use
                    subSampMethod, ... % method of subsampling
                    fixSupportEstimates, ... % condition on supports estimated on full data?
                    suppEstOpt, ... % support estimation method
                    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
                    alpha, ... % elastic net mixing parameter
                    maxIter, ... % maximum number of iterations (cycles through coordinates)
                    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
                    dist); % response distribution (1 for poisson, 2 for gaussian)
                
                % estimate for case 2
                suppEstOpt = 2;
                [A_hats(:, :, 2, dataNum), nu_hats(:, :, 2, dataNum), convChecks(dataNum, 2), compTimes(dataNum, 2)] = ...
                    method1(...
                    data, ... % data (T x p) matrix (descending time order)
                    lambda_path, ... % regularization path
                    nSamp, ... % number of subsamples to use
                    subSampMethod, ... % method of subsampling
                    fixSupportEstimates, ... % condition on supports estimated on full data?
                    suppEstOpt, ... % support estimation method
                    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
                    alpha, ... % elastic net mixing parameter
                    maxIter, ... % maximum number of iterations (cycles through coordinates)
                    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
                    dist); % response distribution (1 for poisson, 2 for gaussian)
                
                % estimate for case 5
                suppEstOpt = 1;
                [A_hats(:, :, 3, dataNum), nu_hats(:, :, 3, dataNum), convChecks(dataNum, 3), compTimes(dataNum, 3)] = method2(...
                    data, ... % data (T x p) matrix (descending time order)
                    lambda_path, ... % regularization path
                    nSamp, ... % number of subsamples to use
                    subSampMethod, ... % method of subsampling
                    fixSupportEstimates_inner, ... % condition on supports estimated on full data?
                    fixSupportEstimates_outer, ... % condition on supports estimated on full data?
                    suppEstOpt, ... % support estimation method
                    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
                    threshParVec, ... % thresholding parameter for combining supports
                    nSampThresh, ... % number of folds to use in threshold tuning
                    alpha, ... % elastic net mixing parameter
                    maxIter, ... % maximum number of iterations (cycles through coordinates)
                    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
                    dist); % response distribution (1 for poisson, 2 for gaussian)
                
                % estimate for case 6
                suppEstOpt = 2;
                [A_hats(:, :, 4, dataNum), nu_hats(:, :, 4, dataNum), convChecks(dataNum, 4), compTimes(dataNum, 4)] = method2(...
                    data, ... % data (T x p) matrix (descending time order)
                    lambda_path, ... % regularization path
                    nSamp, ... % number of subsamples to use
                    subSampMethod, ... % method of subsampling
                    fixSupportEstimates_inner, ... % condition on supports estimated on full data?
                    fixSupportEstimates_outer, ... % condition on supports estimated on full data?
                    suppEstOpt, ... % support estimation method
                    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
                    threshParVec, ... % thresholding parameter for combining supports
                    nSampThresh, ... % number of folds to use in threshold tuning
                    alpha, ... % elastic net mixing parameter
                    maxIter, ... % maximum number of iterations (cycles through coordinates)
                    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
                    dist); % response distribution (1 for poisson, 2 for gaussian)
                
                % compute position differences (errors in support set, 1 for FP, -1 for FN)
                positionDiff1 = (A_hats(:, :, 1, dataNum) ~= 0) - (A ~= 0);
                positionDiff2 = (A_hats(:, :, 2, dataNum) ~= 0) - (A ~= 0);
                positionDiff3 = (A_hats(:, :, 3, dataNum) ~= 0) - (A ~= 0);
                positionDiff4 = (A_hats(:, :, 4, dataNum) ~= 0) - (A ~= 0);
                
                % compute squared differences in magnitude
                sqDiff1 = (A_hats(:, :, 1, dataNum) - A).^2;
                sqDiff2 = (A_hats(:, :, 2, dataNum) - A).^2;
                sqDiff3 = (A_hats(:, :, 3, dataNum) - A).^2;
                sqDiff4 = (A_hats(:, :, 4, dataNum) - A).^2;
                
                % capture total position errors
                evalErrors(dataNum, 1, 1) = sum(sum(abs(positionDiff1), 1), 2);
                evalErrors(dataNum, 2, 1) = sum(sum(abs(positionDiff2), 1), 2);
                evalErrors(dataNum, 3, 1) = sum(sum(abs(positionDiff3), 1), 2);
                evalErrors(dataNum, 4, 1) = sum(sum(abs(positionDiff4), 1), 2);
                
                % capture FP
                evalErrors(dataNum, 1, 2) = sum(sum((positionDiff1 > 0), 1), 2);
                evalErrors(dataNum, 2, 2) = sum(sum((positionDiff2 > 0), 1), 2);
                evalErrors(dataNum, 3, 2) = sum(sum((positionDiff3 > 0), 1), 2);
                evalErrors(dataNum, 4, 2) = sum(sum((positionDiff4 > 0), 1), 2);
                
                % capture FN
                evalErrors(dataNum, 1, 3) = sum(sum((positionDiff1 < 0), 1), 2);
                evalErrors(dataNum, 2, 3) = sum(sum((positionDiff2 < 0), 1), 2);
                evalErrors(dataNum, 3, 3) = sum(sum((positionDiff3 < 0), 1), 2);
                evalErrors(dataNum, 4, 3) = sum(sum((positionDiff4 < 0), 1), 2);

                % capture MSE
                evalErrors(dataNum, 1, 4) = sum(sum(sqDiff1, 1), 2)/(p*p);
                evalErrors(dataNum, 2, 4) = sum(sum(sqDiff2, 1), 2)/(p*p);
                evalErrors(dataNum, 3, 4) = sum(sum(sqDiff3, 1), 2)/(p*p);
                evalErrors(dataNum, 4, 4) = sum(sum(sqDiff4, 1), 2)/(p*p);
                
                % print monitor output
                [bestCount, bestIx] = min(evalErrors(dataNum, :, 1));
                fprintf('length %d, dataset %d \n    best %d with %d position errors\n',...
                    T, dataNum, bestIx, bestCount)
                
            end
            
            outMain(outerSetNum).simulations(tNum).T = T;
            outMain(outerSetNum).simulations(tNum).data = {snr, dataRng};
            outMain(outerSetNum).simulations(tNum).estimates = {A_hats, nu_hats};
            outMain(outerSetNum).simulations(tNum).evals = evalErrors;
            outMain(outerSetNum).simulations(tNum).checks = {compTimes, convChecks};
            
            % rolling information capture
            outRolling(tNum).settings = [p, pctNz, T];
            outRolling(tNum).parameters = {A, nu};
            outRolling(tNum).data = {snr, dataRng};
            outRolling(tNum).estimates = {A_hats, nu_hats};
            outRolling(tNum).evals = evalErrors;
            outRolling(tNum).checks = {compTimes, convChecks};
        
            tNum = tNum + 1;
            
        end
        
        % write rolling output
        rollingFilename = ['outRolling_p15/sparsity', ...
            num2str(100*pctNz), ...
            '_rep', ...
            num2str(parRepNum), ...
            '.mat'];
        save(rollingFilename, 'outRolling')
        
        % increment outer count
        outerSetNum = outerSetNum + 1;
        
    end
end


save('simulation_p15_full.mat', 'outMain')