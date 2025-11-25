function Z_Scores = null_model_analysis(M, num_randomizations)
    % Calculates Z-scores for song ubiquity
    % Handles Std=0 to prevent NaN plots
    
    addpath('utils');
    
    fprintf('   > Generating %d Null Models...\n', num_randomizations);
    
    real_ubiquity = full(sum(M, 1));
    rand_ubiquity_accum = zeros(num_randomizations, length(real_ubiquity));
    
    % Use parfor if you have Parallel Toolbox, otherwise change to 'for'
    for i = 1:num_randomizations
        % Generate random network
        M_rand = null_model_bipartite(M);
        rand_ubiquity_accum(i, :) = full(sum(M_rand, 1));
    end
    
    mean_rand = mean(rand_ubiquity_accum);
    std_rand = std(rand_ubiquity_accum);
    
    % --- FIX: Avoid Division by Zero ---
    % If std is 0 (meaning the randomized value never changes), 
    % we set Z to 0 because it's not "statistically significant" (it's structural).
    valid_mask = std_rand > 1e-6;
    
    Z_Scores = zeros(size(real_ubiquity));
    Z_Scores(valid_mask) = (real_ubiquity(valid_mask) - mean_rand(valid_mask)) ./ std_rand(valid_mask);
    
    % Sanity check: Remove Infs
    Z_Scores(isinf(Z_Scores)) = 0;
    Z_Scores(isnan(Z_Scores)) = 0;
end