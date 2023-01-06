% this function simulates data from a Gaussian
% VAR(1) process.

function out = sim_gvar1_data(A, nu, T)

p = size(A, 1);

% add a burn-in period
n_initialize = 500; 
N = n_initialize + T;

% recursively construct series
sim_series = zeros(N, p);
sim_series(1, :) = poissrnd(exp(nu));
for j = 2:N
    eta = A*sim_series(j - 1, :)' + nu;
    sim_series(j, :) = poissrnd(exp(eta));
end

% subset by removing burn in
data_mx = sim_series((n_initialize + 1):N, :);

% return simulated data
out = data_mx;