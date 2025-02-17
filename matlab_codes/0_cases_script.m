% this script illustrates use of codes implementing model aggregation and support aggregation methods
% with synthetic data; authored summer 2020 by t ruiz; revised january 2023

%% simulate data
rng(31720)

% set simulation parameters
tht = 1; % maximum parameter magnitude
positive_prob = 0.3; % approximate proportion of positive entries in A
nsim = 10; % number of realizations from which to estimate SNR
Tsim = 100000; % length of each realization used to estimate SNR
p = 5; % process dimension
pctNz = 0.1; % proportion of A that is nonzero
% nu_entry = fix_nu(p, pctNz); % intercept value
nu_entry = 0.1;
nu = ones(p, 1)*nu_entry; % intercept
% snr_min = 0.5;
% snr_max = 1.5;
% A = A_search(nu, snr_min, snr_max, pctNz, positive_prob, tht, Tsim, nsim); % A matrix
A = sim_unif_gvar1_parameters(p, pctNz, positive_prob, tht);

% generate data
T = 500; % series length (for data)
[data, snr] = sim_data_snr(nu, A, T, 0, 100); 
test_ix = 1:floor(0.1*T); 
train_ix = setdiff(1:T, test_ix);
newdata = data(test_ix, :);
data = data(train_ix, :);

%% implement methods

% global settings for the lasso
nLam = 50; % regularization path length
lambda_path = logspace(4, 1.5, nLam); % regularization path
alpha = 0.99; % elastic net mixing parameter
maxIter = 200; % maximum number of cycles through coordinates in coordinate descent
convCrit = 10^(-6); % convergence criterion (normalized L1 distance between iterations)
dist = 1; % response distribution flag (1 for poisson, 2 for gaussian)

% global method settings
nSamp = 10; % number of subsamples to use in model selection or aggregation
subSampMethod = 1; % method of subsampling; see subsample.m for details
nSampSuppEst = 8; % number of subsamples to use in support aggregation, if applicable

% benchmark method
fixSupportEstimates = 0;
suppEstOpt = 1;

[A_hat, nu_hat, ConvCheck, CompTime] = method1(...
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


% support aggregation

fixSupportEstimates = 0;
suppEstOpt = 2;

[A_hat, nu_hat, ConvCheck, CompTime] = method1(...
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


% model aggregation 
fixSupportEstimates_inner = 0;
fixSupportEstimates_outer = 0;
suppEstOpt = 1;
threshPar = [0.5 0.6 0.7 0.8 0.9 1];
nSampThresh = 8;

[A_hat, nu_hat, ConvCheck, CompTime] = method2(...
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

% model aggregation + support aggregation
fixSupportEstimates_inner = 0;
fixSupportEstimates_outer = 0;
suppEstOpt = 2;
threshPar = [0.5 0.6 0.7 0.8 0.9 1];
nSampThresh = 8;

[A_hat, nu_hat, ConvCheck, CompTime] = method2(...
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
