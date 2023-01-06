% this function generates sparse parameters for
% a Poisson GVAR(1) process

function A = sim_unif_gvar1_parameters(...
    p, ... % process dimension
    pctNZ, ... % sparsity, as percent nonzero
    positive_prob, ... % approximate proportion of positive entires
    trunc) % maximum parameter magnitude

% default settings
if nargin < 2
    pctNZ = 1/p;
    positive_prob = 0.5;
    trunc = 2;
    tht = 0.5;
end

% calculate number of nonzero parameters to generate
numNZ = round(p*p*pctNZ);

% generate parameters between -2 and 2 favoring larger magnitudes
u_smp = unifrnd(0, trunc, numNZ, 1); % uniform sample for inverse cdf transform
NZcoef = (2*binornd(1, positive_prob, numNZ, 1) - 1).*(trunc - u_smp); %% randomly choose sign

% % NEGATIVE-SIGNED PARAMETER ALLOCATION (RANDOM)

% randomly allocate to transition matrix positions
NZ_neg = sum(NZcoef < 0); %% number of negative nonzero parameters
NZix_neg = randi(p^2, NZ_neg, 1); %% randomly choose indices
A_vec = zeros(p^2, 1); %% create vector of matrix entries
A_vec(NZix_neg) = NZcoef(NZcoef < 0); %% assign negative parameters

% % POSITIVE-SIGNED PARAMETER ALLOCATION (STRUCTURED, MAX PATH LENGTH 1)

% split nodes (1 thru p) into an influencing set and a receiving set
prop_inf = 0.5; %% set proportion of nodes that are influencing
node_inf = datasample(1:p, round(p*prop_inf), 'Replace', false); %% randomly choose influencing nodes
node_rec = setdiff(1:p, node_inf); %% determine receiving nodes

% find influencing positions in vectorized transition matrix
infCol_ix_cell = arrayfun(@(j) ((j - 1)*p + 1):((j)*p), node_inf, 'UniformOutput', false);
infCol_ix = reshape(cell2mat(infCol_ix_cell), 1, p*length(node_inf));

% find receiving positions in vectorized transition matrix
recRow_ix_cell = arrayfun(@(j) (0:(p - 1))*p + j, node_rec, 'UniformOutput', false);
recRow_ix = reshape(cell2mat(recRow_ix_cell), 1, p*length(node_rec));

% take intersection
allowed_ix = intersect(infCol_ix, recRow_ix);

% randomly allocate positive parameters to permitted positions
NZ_pos = sum(NZcoef > 0); %% number of positvie nonzero parameters
NZix_pos = datasample(allowed_ix, NZ_pos, 'Replace', false); %% choose indices
A_vec(NZix_pos) = NZcoef(NZcoef > 0); %% assign positive parameters

% output
A = reshape(A_vec, p, p); %% rearrange as matrix