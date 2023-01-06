% this function arranges multiple time series
% into *multivariate* regression format for 
% fitting a VAR(D) model.

% note 1: data should be input as a (T x p) 
%         matrix with rows in *descending*
%         time order

% note 2: this function was originally written
%         to convolve the process history with
%         a set of basis functions. to output
%         for fitting a VAR(D) model, use
%         bases = ones(1, D)

function [X_mx, Y_mx] = regression_format(...
    data, ... % a vector time series
    bases, ... % see note 2
    intercept_flag) % include intercept columns?

% determine data and basis dimensions
[T, p] = size(data);
[n_basis, n_lag] = size(bases);

% store response matrix
Y_mx = data(1:(T - n_lag), :);

% construct lagged matrix
if intercept_flag == 1
    X_mx = zeros(T - n_lag, n_basis*p + 1);
    for j = 2:(T - n_lag + 1)
        lag_mx = data(j:(j + n_lag - 1), :);
        f_mx = bases*lag_mx;
        X_mx((j - 1), :) = [1; reshape(f_mx', n_basis*p, 1)];
    end
else
    X_mx = zeros(T - n_lag, n_basis*p);
    for j = 2:(T - n_lag + 1)
        lag_mx = data(j:(j + n_lag - 1), :);
        f_mx = bases*lag_mx;
        X_mx((j - 1), :) = reshape(f_mx', n_basis*p, 1);
    end
end