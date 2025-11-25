function [RCA, M] = compute_rca(X)
    % Calculates Revealed Comparative Advantage based on Hidalgo (2009)
    % Input: X (Weighted Streams Matrix)
    % Output: RCA Matrix, M (Binary Matrix where RCA >= 1)
    
    % Sums
    R_total = sum(X, 2); % Total streams per region
    S_total = sum(X, 1); % Total streams per song
    Grand_total = sum(R_total);
    
    % Numerator: Share of song in region
    % Using bsxfun for broadcasting division
    share_regional = bsxfun(@rdivide, X, R_total);
    
    % Denominator: Share of song globally
    share_global = S_total / Grand_total;
    
    % RCA
    RCA = bsxfun(@rdivide, share_regional, share_global);
    
    % Binarize (The Topology)
    M = sparse(RCA >= 1);
end