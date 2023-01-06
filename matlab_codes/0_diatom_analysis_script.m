% example analysis producing interaction network from sediment core data on diatom taxon abundances
% authored by t ruiz january 2023

% load data
load("../data/diatom.mat")

%% pre-11kyr analysis
data = struct2table(pre).Variables;
rslts_pre = cell(3, 4);

% fix settings for the lasso
alpha = 0.99; % elastic net mixing parameter
maxIter = 500; % maximum number of cycles through coordinates in coordinate descent
convCrit = 10^(-6); % convergence criterion (normalized L1 distance between iterations)
dist = 1; % response distribution flag (1 for poisson, 2 for gaussian)

nLam = 50; % regularization path length
lambda_path = logspace(4.3, 2, nLam); % regularization path
% test = try_settings(data, lambda_path, dist, alpha, maxIter, convCrit); % check for convergence and support size

% global method settings
nSamp = 7;
subSampMethod = 1;
nSampSuppEst = 6;

% naive method (grid search to optimize e{betahat(test, lambda)})
[rslts_pre{1, 1}, rslts_pre{1, 2}, rslts_pre{1, 3}, rslts_pre{1, 4}] = method0(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist); % response distribution (1 for poisson, 2 for gaussian)


% benchmark method
fixSupportEstimates = 0;
suppEstOpt = 1;

[rslts_pre{2, 1}, rslts_pre{2, 2}, rslts_pre{2, 3}, rslts_pre{2, 4}] = method1(...
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

% model+support aggregation method
fixSupportEstimates_inner = 0;
fixSupportEstimates_outer = 0;
suppEstOpt = 2;
threshPar = [0.5 0.7 0.8 1];
nSampThresh = 6;

[rslts_pre{3, 1}, rslts_pre{3, 2}, rslts_pre{3, 3}, rslts_pre{3, 4}] = method2(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    fixSupportEstimates_inner, ... % condition on supports estimated on full data?
    fixSupportEstimates_outer, ... % condition on supports estimated on full data?
    suppEstOpt, ... % support estimation method
    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
    threshPar, ... % thresholding parameter for combining supports
    nSampThresh, ... % number of folds to use in threshold tuning
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist); % response distribution (1 for poisson, 2 for gaussian)

save('../results/diatom-pre.mat',"rslts_pre")

%% post 11k yrs ago
data = struct2table(post).Variables;
rslts_post = cell(3, 4);

% fix settings for the lasso
alpha = 0.99; % elastic net mixing parameter
maxIter = 300; % maximum number of cycles through coordinates in coordinate descent
convCrit = 10^(-6); % convergence criterion (normalized L1 distance between iterations)
dist = 1; % response distribution flag (1 for poisson, 2 for gaussian)

nLam = 50; % regularization path length
lambda_path = logspace(4.3, 2.5, nLam); % regularization path
% test = try_settings(data, lambda_path, dist, alpha, maxIter, convCrit); % check for convergence and support size

% global method settings
nSamp = 10;
subSampMethod = 1;
nSampSuppEst = 5;

% naive method (grid search to optimize e{betahat(test, lambda)})
[rslts_post{1, 1}, rslts_post{1, 2}, rslts_post{1, 3}, rslts_post{1, 4}] = method0(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist); % response distribution (1 for poisson, 2 for gaussian)

% benchmark method
fixSupportEstimates = 0;
suppEstOpt = 1;

[rslts_post{2, 1}, rslts_post{2, 2}, rslts_post{2, 3}, rslts_post{2, 4}] = method1(...
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

% model+support aggregation method
fixSupportEstimates_inner = 0;
fixSupportEstimates_outer = 0;
suppEstOpt = 2;
threshPar = [0.5 0.7 0.8 1];
nSampThresh = 6;

[rslts_post{3, 1}, rslts_post{3, 2}, rslts_post{3, 3}, rslts_post{3, 4}] = method2(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    fixSupportEstimates_inner, ... % condition on supports estimated on full data?
    fixSupportEstimates_outer, ... % condition on supports estimated on full data?
    suppEstOpt, ... % support estimation method
    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
    threshPar, ... % thresholding parameter for combining supports
    nSampThresh, ... % number of folds to use in threshold tuning
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist); % response distribution (1 for poisson, 2 for gaussian)

save('../results/diatom-post.mat',"rslts_post")
