function [data, snr] = sim_data_snr(nu, A, T, snr_min, snr_max)

condition = 0;
while condition == 0
    data = sim_gvar1_data(A, nu, T);
    data = flipud(data);
    dev1 = error_fn(data, A, nu, 1);
    dev2 = error_fn(data, 0, nu, 1);
    snr = (dev2 - dev1)/dev1;
condition = snr > snr_min && snr < snr_max;
end