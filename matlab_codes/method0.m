function [A_hat, nu_hat, ConvCheck, CompTime] = method0(...
    data, ... % data (T x p) matrix (descending time order)
    lambda_path, ... % regularization path
    nSamp, ... % number of subsamples to use
    subSampMethod, ... % method of subsampling
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

% estimate parameters on full data
% beta_hat(data, lambda)
% compute lasso estimates across path
intercept_idx = 1:(p + 1):(p*(p + 1));
[X_mx, Y_mx] = regression_format(data, 1, 1);
beta0 = zeros(size(X_mx, 2)*size(Y_mx, 2), 1);
[betahat_mx, nIter, ~] = lasso_var_path(...
    X_mx, ...
    Y_mx, ...
    lambda_path, ...
    dist, ...
    alpha, ...
    beta0, ...
    maxIter, ...
    convCrit, ...
    intercept_idx);
ConvCheck(nSamp + 1) = sum(nIter == maxIter);

% generate subsamples
subSamp_data = subsample(data, nSamp, subSampMethod);

% for each subsample, compute errors associated to each lambda
parfor samp = 1:nSamp
    % partition data into training and test
    % (train.j, test.j) <- subsample(data)
    train_data = subSamp_data{samp, 1};
    test_data = subSamp_data{samp, 2};

    % estimate parameters on training data
    % beta_hat <- beta_hat(train.j, lambda)
    [x, y] = regression_format(data, 1, 1);
    beta0 = zeros(size(x, 2)*size(y, 2), 1);
    [est, iter, ~] = lasso_var_path(...
        x, ...
        y, ...
        lambda_path, ...
        dist, ...
        alpha, ...
        beta0, ...
        maxIter, ...
        convCrit, ...
        intercept_idx);
    ConvCheck(samp) = sum(iter == maxIter);

    % cycle through estimated supports
    for k = 1:K
        mxEst = reshape(est(:, k), p + 1, p);
        A_hat = mxEst(2:(p + 1), :)';
        nu_hat = mxEst(1, :)';


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
mxEst = reshape(betahat_mx(:, lambdaOptIx), p + 1, p);
A_hat = mxEst(2:(p + 1), :)';
nu_hat = mxEst(1, :)';

ConvCheck = sum(ConvCheck);
CompTime = toc;