% this function performs matrix algebra for
% coordinate updates in enet-penalized VAR

function [num_sum, dem_sum] = ... 
    var_coord_update_sums(beta_k, ... % current estimate
    X_mx, ... % lag matrix
    Y_mx, ... % response matrix
    z, ... % working response at current iteration
    w, ... % weights at current iteration
    row, ... % row index of coordinate being updated
    column) % column index of coordinate being updated

% find beta positions corresponding to column
[~, p] = size(Y_mx);
b = beta_k(((column - 1)*(p + 1) + 1):(column*(p + 1)));

% drop column of lag matrix corresponding 
% to coordinate being updated
incl_idx = setdiff(1:size(X_mx, 2), row); 

% calculate predictor *without* that column 
% (for partial residual)
z_tilde = X_mx(:, incl_idx) * b(incl_idx);

% (z - z~)' W x_j
num_sum = w' * (X_mx(:, row) .* (z - z_tilde));

% x_j' W x_j
dem_sum = w' * (X_mx(:, row) .* X_mx(:, row));