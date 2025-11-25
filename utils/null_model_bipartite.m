function M_rand = null_model_bipartite(M)
    % Generates a random bipartite graph preserving degrees
    % Simplest method: Swap edges
    
    [rows, cols] = find(M);
    n_edges = length(rows);
    iterations = n_edges * 5; % Rule of thumb for mixing
    
    M_rand = M;
    
    for i = 1:iterations
        % Pick two random edges: (u,v) and (x,y)
        idx = randperm(n_edges, 2);
        
        u = rows(idx(1)); v = cols(idx(1));
        x = rows(idx(2)); y = cols(idx(2));
        
        % Check if swap is valid (no duplicate edges created)
        if M_rand(u, y) == 0 && M_rand(x, v) == 0
            % Perform Swap
            M_rand(u, v) = 0;
            M_rand(x, y) = 0;
            M_rand(u, y) = 1;
            M_rand(x, v) = 1;
            
            % Update index list to reflect swap
            cols(idx(1)) = y;
            cols(idx(2)) = v;
        end
    end
end