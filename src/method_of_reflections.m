function [Kc, Kp] = method_of_reflections(M, iterations)
    % Calculates Diversity/Ubiquity iteratively
    
    [num_c, num_p] = size(M);
    
    % Initial Conditions (Level 0: Degree)
    kc_0 = sum(M, 2); % Diversity
    kp_0 = sum(M, 1); % Ubiquity
    
    Kc = zeros(num_c, iterations);
    Kp = zeros(num_p, iterations);
    
    kc_curr = kc_0;
    kp_curr = kp_0;
    
    for n = 1:iterations
        % Calculate averages weighted by connection
        % (Matrix multiplication handles the summation logic efficiently)
        
        % Refine Country Complexity (Avg Ubiquity of songs they listen to)
        kc_next = (M * kp_curr') ./ kc_0;
        
        % Refine Song Complexity (Avg Diversity of countries listening to it)
        kp_next = (M' * kc_curr) ./ kp_0';
        
        % Normalize to keep values manageable (Mean 0, Std 1)
        kc_next = (kc_next - mean(kc_next)) / std(kc_next);
        kp_next = (kp_next - mean(kp_next)) / std(kp_next);
        
        % Update
        kc_curr = kc_next;
        kp_curr = kp_next';
        
        % Store
        Kc(:, n) = kc_curr;
        Kp(:, n) = kp_curr;
    end
end