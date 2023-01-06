function [value, frequency] = countInstances(x)

value = unique(x);
nVals = length(value);
frequency = zeros(nVals, 1);

for val = 1:length(value)
    frequency(val) = sum(value(val) == x);
end