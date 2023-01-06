function [threshSupports, ConvCheck, CompTime] = method2_inner(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
    fixSupportEstimates, ... % condition on supports estimated on full data?
    suppEstOpt, ... % support estimation method
    nSampSuppEst, ... % number of folds to use in support estimation (if option == 2)
    threshPar, ... % thresholding parameter for combining supports
    alpha, ... % elastic net mixing parameter
    maxIter, ... % maximum number of iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (normalized L1 distance between iterations)
    dist) % response distribution (1 for poisson, 2 for gaussian)

% start timer
tic;

% data and path dimensions
K = length(lambda_path);

% storage for error metrics and convergence checks
optimalSupports = cell(nSamp, 1);
ConvCheck = zeros(nSamp + 1, 1);

% estimate supports on full data
% S_hat(data, lambda)
[S_hat, ConvCheck(nSamp + 1), ~] = estimate_supports(...
    data, ...
    suppEstOpt, ...
    nSampSuppEst, ...
    lambda_path, ...
    1, ...
    dist, ...
    alpha, ...
    maxIter, ...
    convCrit);

% generate subsamples
subSamp_data = subsample(data, nSamp, subSampMethod);

% for each subsample, compute errors associated to each lambda
parfor samp = 1:nSamp    
    % partition data into training and test
    % (train.j, test.j) <- subsample(data)
    train_data = subSamp_data{samp, 1};
    test_data = subSamp_data{samp, 2};
    
    % if conditioning on supports
    if fixSupportEstimates == 1
        % make a copy of estimated support sets
        S_hat_train = S_hat;
    else
        % estimate supports on training data
        % S_hat <- S_hat(train.j, lambda)
        [S_hat_train, ConvCheck(samp), ~] = estimate_supports(...
            train_data, ...
            suppEstOpt, ...
            nSampSuppEst, ...
            lambda_path, ...
            1, ...
            dist, ...
            alpha, ...
            maxIter, ...
            convCrit);
    end
    
    % create storage for evaluation metrics
    eval_metrics = zeros(K, 1);
    
    % cycle through estimated supports
    for k = 1:K
        % estimate parameters
        % beta_hat.k <- beta_hat(train.j, S_hat[lambda.k])
        [A_hat, nu_hat, ~] = constrained_var(...
            train_data, ...
            S_hat_train{k}, ...
            dist, ...
            maxIter, ...
            convCrit);
        
        % compute deviance
        % e.j[lambda.k] <- e(test.j, beta_hat.k)
        eval_metrics(k) = error_fn(...
            test_data, ...
            A_hat, ...
            nu_hat, ...
            dist);
    end
    
    % find optimal lambda
    % lambda* <- argmin_lambda e.j
    [~, lambdaOptIx] = min(eval_metrics);
    
    % return corresponding support set
    optimalSupports{samp} = S_hat_train{lambdaOptIx};
end

% threshold optimal supports
nThresh = length(threshPar);
concatenated_supports = cat(1, optimalSupports{:, 1});
[index, frequency] = countInstances(concatenated_supports);
threshSupports = cell(nThresh, 1);
for thresh = 1:nThresh
    threshSupports{thresh} = index(frequency >= threshPar(thresh)*nSamp);
end

ConvCheck = sum(ConvCheck);
CompTime = toc;