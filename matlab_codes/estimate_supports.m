function [out, cCheck, run_time] = estimate_supports( ...
    data, ... % data (T x p) matrix (rows in descending time order)
    estOpt, ... % estimation option, 1 for lasso, 2 for blasso
    nFolds, ... % number of bootstrap samples
    lambda_path, ... % regularization path
    s, ... % fuzzy intersection parameter
    dist, ... % response distribution (1 for poisson, 2 for gaussian)
    alpha, ... % elastic net mixing parameter
    maxIter, ... % iteration limit (max number of cycles through coordinates)
    convCrit) % convergence criterion (normalized L1 distance between iterations)

% start timer
tic;

% determine number of regularization parameters
K = size(lambda_path, 2);
[~, p] = size(data);

% find intercept positions for vectorized model
intercept_idx = 1:(p + 1):(p*(p + 1));

% % LASSO ESTIMATION
if estOpt == 1
    % arrange response and covariate matrices
    [x, y] = regression_format(data, ...
        1, 1);
    
    % initialize
    beta0 = zeros(size(x, 2)*size(y, 2), 1);
    
    % compute lasso estimate
    [out, convCheck] = lasso_supports( ...
        x, ...
        y, ...
        lambda_path, ...
        intercept_idx,...
        dist, ...
        alpha, ...
        beta0, ...
        maxIter, ...
        convCrit);
    
    cCheck = sum(convCheck, 1);
end

% % BLASSO ESTIMATION (argument estOpt = 2)
if estOpt == 2
    % create storage for estimated support sets
    estimated_supports = cell(K, nFolds);
    convCheck = zeros(K, nFolds);
    
    % generate subsamples
    subSamp_data = subsample(data, nFolds, 1);
    
    % find lasso supports for each subsample
    parfor fold = 1:nFolds
        train_data = subSamp_data{fold, 1};
        
        % vectorize bootstrap sample
        [x, y] = regression_format(train_data, 1, 1);
        
        % initialize
        beta0 = zeros(size(x, 2)*size(y, 2), 1);
        
        % estimate support sets
        [estimated_supports(:, fold), convCheck(:, fold)] = lasso_supports( ...
            x, ...
            y, ...
            lambda_path, ...
            intercept_idx, ...
            dist, ...
            alpha, ...
            beta0, ...
            maxIter, ...
            convCrit);
    end
    
    % create storage for intersection of support sets
    support_intersection = cell(K, 1);
    
    % concatenate supports for each regularization parameter and threshold
    % frequency
    for k = 1:K
        concatenated_supports = cat(1, estimated_supports{k, :});
        
        % count the number of occurrences of each unique index in the
        % concatenated support sets
        [index, frequency] = countInstances(concatenated_supports);
        
        % store indices appearing at least 100s% of the time
        support_intersection{k} = index(frequency >= s*nFolds);
    end
     
    % output
    out = support_intersection;
    cCheck = sum(sum(convCheck, 2), 1);
end

run_time = toc;