% this function computes MLEs for a constrained
% subset of VAR model parameters (setting the
% remaining parameters to zero) using coordinate 
% descent

function [A_hat, nu_hat, iter, epsilon] = constrained_var( ...
    data, ...
    support_set, ... % index of locations to estimate 
    dist, ... % response distribution (1 for poisson, 2 for gaussian)
    maxIter, ... % maximum number of cycles through coordinates
    convCrit) % convergence criterion (normalized L1 distance between iterations)
    
% data dimensions
[~, p] = size(data);

% arrange response and covariate matrices
[X_mx, Y_mx] = regression_format(data, ...
    1, 1);

% initialization, set specified parameters to 0.1 and others to zero
iter = 0;
epsilon = 1;
beta_k = zeros(size(Y_mx, 2)*size(X_mx, 2), 1);
beta_k(support_set) = 0.01;

% perform active set coordinate descent iterations
active_flag = 1;

while (epsilon > convCrit) && (iter < maxIter)
    [beta_k, epsilon] = update_var_coords(...
        beta_k, ...
        X_mx, ...
        Y_mx, ...
        0, ...
        0, ...
        dist, ...
        zeros(length(beta_k), 1), ...
        active_flag);
    iter = iter + 1;
end

mxEst = reshape(beta_k, p + 1, p);
A_hat = mxEst(2:(p + 1), :)';
nu_hat = mxEst(1, :)';