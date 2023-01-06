function [A_hat, nu_hat, ConvCheck, CompTime] = method2(...
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
    dist) % response distribution (1 for poisson, 2 for gaussian)

% start timer
tic;

% length of threshold path
nThresh = length(threshPar);

% storage for error metrics and convergence checks
eval_metrics = zeros(nThresh, nSampThresh);
ConvCheck = zeros(nSampThresh + 1, 1);

% compute thresholded supports on full dataset
[S_hat, ConvCheck(nSampThresh + 1), ~] = method2_inner(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    fixSupportEstimates_inner, ... % condition on supports estimated on full data?
    suppEstOpt, ... % support estimation method
    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
    threshPar, ... % thresholding parameter for combining supports
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist); % response distribution (1 for poisson, 2 for gaussian)

% generate subsamples
subSamp_data = subsample(data, nSampThresh, subSampMethod);

% for each subsample, compute errors associated to each lambda
for samp = 1:nSampThresh
    % partition data into training and test
    % (train.j, test.j) <- subsample(data)
    train_data = subSamp_data{samp, 1};
    test_data = subSamp_data{samp, 2};
    
    % if conditioning on supports
    if fixSupportEstimates_outer == 1
        % make a copy of estimated support sets
        S_hat_train = S_hat;
    
    % otherwise
    else
        % estimate supports on training data
        % S_hat <- S_hat(train.j, lambda)
        [S_hat_train, ConvCheck(samp), ~] = method2_inner(...
            train_data, ... % data (T x p) matrix (descending time order)
            lambda_path, ... % regularization path
            nSamp, ... % number of subsamples to use
            subSampMethod, ... % method of subsampling
            fixSupportEstimates_inner, ... % condition on supports estimated on full data?
            suppEstOpt, ... % support estimation method
            nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
            threshPar, ... % thresholding parameter for combining supports
            alpha, ... % elastic net mixing parameter
            maxIter, ... % maximum number of iterations (cycles through coordinates)
            convCrit, ... % convergence criterion (normalized L1 distance between iterations)
            dist); % response distribution (1 for poisson, 2 for gaussian)
        
    end
    
    % cycle through estimated supports
    for thresh = 1:nThresh
        % estimate parameters
        % beta_hat.k <- beta_hat(train.j, S_hat[lambda.k])
        [A_hat, nu_hat, ~] = constrained_var(...
            train_data, ...
            S_hat_train{thresh}, ...
            dist, ...
            maxIter, ...
            convCrit);
        
        % compute deviance
        % e.j[lambda.k] <- e(test.j, beta_hat.k)
        eval_metrics(thresh, samp) = error_fn(...
            test_data, ...
            A_hat, ...
            nu_hat, ...
            dist);
    end
end

% return optimal threshold
% thresh* <- argmin_thresh mean(e)
eBar = mean(eval_metrics, 2);
[~, threshOptIx] = min(eBar);

% estimate parameters on original data for optimal lambda
% return betahat(data, S_hat(data, lambda*))
[A_hat, nu_hat, ~] = constrained_var(...
    data, ...
    S_hat{threshOptIx}, ...
    dist, ...
    maxIter, ...
    convCrit);

ConvCheck = sum(ConvCheck);
CompTime = toc;

