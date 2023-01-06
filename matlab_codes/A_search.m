function A = A_search(nu, snr_min, snr_max, ...
    pctNZ, positive_prob, tht, T, nsim)

p = length(nu);

% default settings
if nargin < 4
    pctNZ = 1/p;
    positive_prob = 0.4;
    trunc = 1.5;
    tht = 0.5;
%    snr_min = 0.5;
%    snr_max = 1.5;
    T = 500;
    nsim = 20;
end

% repeatedly generate A's until metric falls within target range
condition = 0;
while condition == 0
    A = sim_unif_gvar1_parameters(p, pctNZ, ...
        positive_prob, tht);
    [snr, ~] = sim_snr(nu, A, T, nsim)
    condition = snr > snr_min && snr < snr_max;
end