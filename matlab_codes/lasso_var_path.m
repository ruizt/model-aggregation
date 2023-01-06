% this function implements pathwise coordinate
% descent for enet penalized glm

function [beta_mx, nIter, Eps] = ...
    lasso_var_path(...
    X_mx, ... % lag matrix
    Y_mx, ... % response matrix
    lambda_path, ... % regularization path
    dist, ... % response distribution
    alpha, ... % elastic net mixing parameter
    beta_0, ... % starting value for initialization
    maxIter, ... % maximum iterations (cycles through coordinates)
    convCrit, ... % convergence criterion (L1 distance)
    intercept_idx) % index of intercept locations (for vectorized VAR)

% determine length of regularization path and
% create empty outputs
K = max(size(lambda_path));
beta_mx = zeros(size(X_mx, 2)*size(Y_mx, 2), K);
nIter = zeros(K, 1);
Eps = zeros(K, 1);

% order regularization path in descending order
[lambda, lambda_order] = sort(lambda_path, 'descend');

% for each regularization parameter...
for k = 1:K    
    % use warm starts after the first solution
    if k > 1
        beta_0 = beta_mx(:, lambda_order(k - 1));
    end
    
    % compute lasso estimate
    [beta_mx(:, lambda_order(k)), nIter(k), Eps(k)] = ...
        lasso_var_single( ...
        X_mx, ... % design matrix
        Y_mx, ... % response variable
        lambda(k), ... % regularization parameter
        dist, ... % response distribution
        alpha, ... % elastic net mixing parameter
        beta_0, ... % starting value for initialization
        maxIter, ... % maximum iterations (cycles through coordinates)
        convCrit, ... % convergence criterion (L1 distance)
        intercept_idx); % index of intercept locations (for vectorized VAR)
end