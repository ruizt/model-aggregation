function out = subsample(data, ...
    nSamp, ...
    method, ...
    blockLength)

% determine data dimensions
[T, ~] = size(data);

% create storage
out = cell(nSamp, 2);

% method 1: evenly divide data into blocks; hold out one
% block at a time
if method == 1
    subInt_length = floor(T./nSamp);
    for samp = 1:nSamp
        trainIx = setdiff(1:T, ((samp - 1)*subInt_length + 1):(samp*subInt_length));
        testIx = (((samp - 1)*subInt_length + 1):(samp*subInt_length));
        out{samp, 1} = data(trainIx, :);
        out{samp, 2} = data(testIx, :);
    end
end

% method 2: randomly hold out a block (default length as above)
if method == 2
    if nargin < 4
        blockLength = floor(T./nSamp);
    end
    for samp = 1:nSamp
        blockStart = randi(T - blockLength, 1, 1);
        testIx = blockStart:(blockStart + blockLength);
        trainIx = setdiff(1:T, testIx);
        out{samp, 1} = data(trainIx, :);
        out{samp, 2} = data(testIx, :);
    end
end