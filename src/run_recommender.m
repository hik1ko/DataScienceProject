function run_recommender(M, Sim_Countries, regions, songs, target_country, outDir)
    fprintf('[VIZ] Generating Recommendation Plot for %s...\n', target_country);
    
    idx = find(strcmpi(regions, target_country));
    if isempty(idx), return; end
    
    % Neighbor Logic
    sims = Sim_Countries(idx, :);
    [sorted_sim, sort_idx] = sort(sims, 'descend');
    neighbors = sort_idx(2:6); 
    neighbor_names = regions(neighbors);
    neighbor_weights = full(sorted_sim(2:6));
    
    % Score Calculation
    current_songs = M(idx, :);
    candidates = find(current_songs == 0);
    if isempty(candidates), return; end
    
    N_Mat = M(neighbors, candidates); 
    scores = (neighbor_weights * N_Mat) ./ sum(neighbor_weights);
    
    % Get Top 10
    [final_scores, sort_s] = sort(scores, 'descend');
    n_plot = min(10, length(final_scores));
    if n_plot == 0, return; end
    
    top_idx = candidates(sort_s(1:n_plot));
    top_names = songs(top_idx);
    top_vals = final_scores(1:n_plot)';
    
    % Shorten names to prevent layout crunch
    for i = 1:length(top_names)
        if strlength(top_names(i)) > 50
            top_names(i) = extractBefore(top_names(i), 47) + "...";
        end
    end
    
    % --- HIGH FIDELITY PLOTTING ---
    f = figure('Position', [100, 100, 1200, 600], 'Color', 'w');
    f.GraphicsSmoothing = 'on'; % Force anti-aliasing
    
    b = barh(flipud(top_vals), 0.7); % Thinner bars for cleaner look
    b.FaceColor = [0.4660 0.6740 0.1880];
    b.EdgeColor = 'none'; % Remove jagged edges on bars
    
    ax = gca;
    ax.YTick = 1:n_plot;
    ax.YTickLabel = flipud(top_names);
    ax.XLim = [0 1];
    
    % Font Settings for Sharpness
    ax.FontName = 'Arial'; 
    ax.FontSize = 11;
    ax.FontWeight = 'bold';
    ax.XColor = 'k'; 
    ax.YColor = 'k';
    ax.Color = 'w';
    
    % Critical Margin Fix
    set(ax, 'Position', [0.55 0.15 0.4 0.75]);
    
    xlabel('Recommendation Confidence Score', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
    
    % Titles
    t = title(sprintf('Top Song Recommendations for %s', target_country), ...
        'Interpreter', 'none', 'FontSize', 16, 'Color', 'k');
        
    s = subtitle(sprintf('Based on structural similarity to: %s', strjoin(neighbor_names, ', ')), ...
        'FontSize', 10, 'Color', [0.3 0.3 0.3]); % Dark Gray subtitle
    
    grid on;
    ax.GridAlpha = 0.3; % Subtle grid
    
    drawnow;
    
    % EXPORT AT 600 DPI (Print Quality)
    save_path = fullfile(outDir, sprintf('Recs_%s.png', target_country));
    exportgraphics(f, save_path, 'Resolution', 600);
    
    fprintf('[DONE] Recommender plot saved (High Res).\n');
end