function [X, regions, songs] = build_bipartite(T)
    % Converts Table to Sparse Adjacency Matrix X
    % AND FILTERS out "Regional" songs (appearing in < 6 countries)
    
    [regions, ~, rIdx] = unique(T.region);
    [songs_raw, ~, sIdx] = unique(T.SongID);
    
    num_regions = length(regions);
    num_songs_raw = length(songs_raw);
    
    % Initial Matrix
    X_raw = sparse(rIdx, sIdx, T.Streams, num_regions, num_songs_raw);
    
    % --- FILTERING STEP (STRICTER) ---
    % Calculate how many countries listen to each song (RCA Pre-check)
    % We check raw presence first
    Countries_Per_Song = sum(X_raw > 0, 1);
    
    % FIX: Increase threshold to 6. 
    % This removes "Regional Blocks" (e.g., songs only popular in CIS or Scandinavia)
    % and focuses on songs that travel globally.
    valid_songs_mask = Countries_Per_Song >= 6;
    
    % Use full() for fprintf compatibility
    count_removed = full(sum(~valid_songs_mask));
    
    fprintf('   > Filtering: Removing %d "Regional/Local" songs (present in < 6 countries)...\n', ...
        count_removed);
    
    % Apply Filter
    X = X_raw(:, valid_songs_mask);
    songs = songs_raw(valid_songs_mask);
    
    % Re-filter regions (remove empty rows if any)
    valid_regions_mask = sum(X, 2) > 0;
    X = X(valid_regions_mask, :);
    regions = regions(valid_regions_mask);
    
    fprintf('   > Final Network: %d Regions x %d Songs\n', length(regions), length(songs));
end