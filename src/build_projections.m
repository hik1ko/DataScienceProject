function [Sim_Countries, Sim_Songs] = build_projections(M)
    % Projects the bipartite graph into monopartite similarity graphs
    % Memory-Optimized for Large Networks (Song-Song)
    
    fprintf('   > Calculating Country-Country Similarity (Jaccard)...\n');

    % ------------------------------------------------------------
    % 1. Country-Country Similarity (Small: ~70 x 70)
    % ------------------------------------------------------------
    % We can keep this dense as it's small and fast
    Intersection = M * M';
    Deg = sum(M, 2);
    
    % Broadcast addition for Union
    Union = bsxfun(@plus, Deg, Deg') - Intersection;
    
    Sim_Countries = Intersection ./ Union;
    
    % Cleanup
    Sim_Countries(isnan(Sim_Countries)) = 0;
    Sim_Countries = Sim_Countries - diag(diag(Sim_Countries)); 
    
    
    % ------------------------------------------------------------
    % 2. Song-Song Similarity (Large: ~32k x 32k) - SPARSE MODE
    % ------------------------------------------------------------

    % Calculate Intersections (Sparse Matrix Multiplication)
    Intersection_S = M' * M;
    
    % Get Degrees as a full vector
    Deg_S = full(sum(M, 1))'; % Column vector (S x 1)
    
    % Extract Non-Zero elements (Triplets)
    % We only calculate Jaccard where Intersection > 0 to save memory
    [rows, cols, inter_vals] = find(Intersection_S);
    
    % Calculate Union for these specific pairs only
    % Union(i,j) = Deg(i) + Deg(j) - Intersection(i,j)
    union_vals = Deg_S(rows) + Deg_S(cols) - inter_vals;
    
    % Calculate Jaccard
    sim_vals = inter_vals ./ union_vals;
    
    % Reconstruct Sparse Matrix
    S = size(M, 2);
    Sim_Songs = sparse(rows, cols, sim_vals, S, S);
    
    % Remove self-loops (diagonal)
    Sim_Songs = Sim_Songs - diag(diag(Sim_Songs));
    