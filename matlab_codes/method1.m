function [A_hat, nu_hat, ConvCheck, CompTime] = method1(...
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
    dist) % response distribution (1 for poisson, 2 for gaussian)

% start timer
tic;

% data and path dimensions
[~, p] = size(data);
K = length(lambda_path);

% storage for error metrics and convergence checks
eval_metrics = zeros(K, nSamp);
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
        eval_metrics(k, samp) = error_fn(...
            test_data, ...
            A_hat, ...
            nu_hat, ...
            dist);
    end
end

% return optimal lambda
% lambda* <- argmin_lambda mean(e)
eBar = mean(eval_metrics, 2);
[~, lambdaOptIx] = min(eBar);

% estimate parameters on original data for optimal lambda
% return betahat(data, S_hat(data, lambda*))
[A_hat, nu_hat, ~] = constrained_var(...
    data, ...
    S_hat{lambdaOptIx}, ...
    dist, ...
    maxIter, ...
    convCrit);



ConvCheck = sum(ConvCheck);
CompTime = toc;