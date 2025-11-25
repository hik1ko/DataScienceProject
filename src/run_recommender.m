function run_recommender(M, Sim_Countries, regions, songs, target_country, outDir)
    fprintf('[VIZ] Generating Recommendation Plot for %s...\n', target_country);
    
    % 1. Find Target
    idx = find(strcmpi(regions, target_country));
    if isempty(idx), return; end
    
    % 2. Find Neighbors
    sims = Sim_Countries(idx, :);
    [sorted_sim, sort_idx] = sort(sims, 'descend');
    neighbors = sort_idx(2:6); % Skip self
    neighbor_names = regions(neighbors);
    neighbor_weights = full(sorted_sim(2:6));
    
    % 3. Calculate Scores
    current_songs = M(idx, :);
    candidates = find(current_songs == 0);
    
    % Safety check: if country listens to everything (unlikely)
    if isempty(candidates)
        fprintf('   [INFO] No candidate songs found for %s.\n', target_country);
        return;
    end
    
    scores = zeros(length(candidates), 1);
    
    % Vectorized score calculation for speed
    % Neighbors Matrix (5 x S_candidates)
    N_Mat = M(neighbors, candidates); 
    % Weighted Sum: (1x5) * (5xS) = (1xS)
    scores = (neighbor_weights * N_Mat) ./ sum(neighbor_weights);
    
    % 4. Plot Top 10
    [final_scores, sort_s] = sort(scores, 'descend');
    
    % Check if we have 10 songs
    n_plot = min(10, length(final_scores));
    if n_plot == 0, return; end
    
    top_idx = candidates(sort_s(1:n_plot));
    top_names = songs(top_idx);
    top_vals = final_scores(1:n_plot)'; % Ensure column vector
    
    % Shorten names if they are too long (prevents cutoff)
    for i = 1:length(top_names)
        if strlength(top_names(i)) > 45
            top_names(i) = extractBefore(top_names(i), 42) + "...";
        end
    end
    
    % 5. Visualization
    f = figure('Position', [100, 100, 900, 500]); % Wider figure
    
    % Flip data so #1 is at the top
    b = barh(flipud(top_vals)); 
    b.FaceColor = [0.4660 0.6740 0.1880]; % Green
    
    % Adjust Axes
    ax = gca;
    ax.YTick = 1:n_plot;
    ax.YTickLabel = flipud(top_names);
    ax.XLim = [0 1];
    
    % FIX: Adjust margins so long names aren't cut off
    % We manually set the axes position to leave 40% space on the left for text
    set(ax, 'Position', [0.4 0.1 0.55 0.8]); 
    
    xlabel('Recommendation Confidence Score');
    
    % Clean Title
    title(sprintf('Top Song Recommendations for %s', target_country), 'Interpreter', 'none');
    subtitle(sprintf('Based on structural similarity to: %s', strjoin(neighbor_names, ', ')), 'FontSize', 9);
    
    grid on;
    
    % Force render before save
    drawnow;
    saveas(f, fullfile(outDir, sprintf('Recs_%s.png', target_country)));
    fprintf('[DONE] Recommender plot saved.\n');
end