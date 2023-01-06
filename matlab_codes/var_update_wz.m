% this function updates the working response 
% and weights *for a specific column* of the
% response matrix

function [w, z] = var_update_wz(...
    beta_k, ... % current estimate
    X_mx, ... % lag matrix
    Y_mx, ... % response matrix
    dist, ... % response distribution (glm)
    column) 

[~, p] = size(Y_mx);
y = Y_mx(:, column);
b = beta_k(((column - 1)*(p + 1) + 1):(column*(p + 1)));

if dist == 1
    w = exp(X_mx*b);
    z = X_mx*b + y./w - 1;
end

if dist == 2
    n = size(X_mx, 1);
    w = ones(n, 1);
    z = y;
end