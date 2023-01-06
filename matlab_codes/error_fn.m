function out = error_fn(test_data, A_hat, nu_hat, dist)

% poisson case: deviance
if dist == 1
    [t_test, ~] = size(test_data);
    
    eta = test_data(2:t_test, :)*A_hat' + nu_hat';
    
    data_ll = test_data(1:(t_test - 1), :);
    logLik = sum(sum(data_ll.*eta - exp(eta), 1), 2);
    
    data_ll_NZ = data_ll(data_ll ~= 0);
    logLik_sat = sum(data_ll_NZ.*log(data_ll_NZ) - data_ll_NZ);
    
    out = 2.*(logLik_sat - logLik);
    % bic = -2.*logLik + sum(sum(A_hat ~= 0, 1), 2).*log(t_test);
end

% gaussian case: mean one-step forecast error
if dist == 2
    mean(...
        var_forecast(test_data, ...
        A_hat, ...
        nu_hat, ...
        1), ...
        2);
end