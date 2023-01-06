function logLik = gvar_ll(A, nu, data)
[T, ~] = size(data);
logLik = sum(sum(data(1:(T - 1), :).*(data(2:T, :)*A' + nu') - ...
    exp(data(2:T, :)*A' + nu'), 1), 2);
