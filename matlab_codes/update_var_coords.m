% this function performs one cycle of coordinate
% descent for VAR, and returns the updated parameter
% estimate and the L1 distance between the old
% estimate and the new estimate

function [beta_kplus1, epsilon] = ...
    update_var_coords(beta_k, ... % current estimate (vectorized)
    X_mx, ... % lag matrix
    Y_mx, ... % response matrix
    lambda, ... % regularization parameter
    alpha, ... % elastic net mixing parameter
    dist, ... % response distribution
    intercept_idx, ... % index of intercept locations (for vectorized VAR)
    active_flag) % flag: do active set iteration (update only nonzero estimates)?

[~, p] = size(Y_mx);
beta_kplus1 = beta_k; % make a copy of current estimate (for updating)

% determine 'active coordinates' (indices to update)
if active_flag == 1
    active_idx = find(beta_k ~= 0)';
else
    active_idx = 1:size(beta_k, 1);
end
n_act = length(active_idx); 

% for each active coordinate...
for coord_idx = 1:n_act
    % retrieve coordinate
    coord = active_idx(coord_idx);
    
    % determine column position of coordinate
    column = floor((coord - 1)/(p + 1)) + 1;
    
    % determine row position of coordinate
    row = mod(coord, p + 1) + ...
        (p + 1)*(mod(coord, p + 1) == 0);
    
    % recalculate working response and weights
    [w, z] = var_update_wz(beta_kplus1, X_mx, Y_mx, dist, column);
    
    % calculate matrix products in update rule
    [q1, q2] = ...
        var_coord_update_sums(beta_kplus1, X_mx, Y_mx, z, w, ...
        row, column);
    
    % calculate update
    if sum(coord == intercept_idx) == 1
        % unpenalized for intercept
        beta_kplus1(coord) = q1./q2;
    else
        % penalized for non-intercept 
        beta_kplus1(coord) = ...
            soft_thresh(q1, lambda*alpha)./...
            (q2 + lambda*(1 - alpha));
    end

    % end after one cycle through active coordinates
end

% calculate sum of absolute differences before 
% and after update
epsilon = sum(abs(beta_kplus1 - beta_k))/length(beta_k);