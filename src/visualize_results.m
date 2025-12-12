function visualize_results(M, Kc, Kp, Z_Scores, Sim_Countries, regions, songs, outDir)
    % Generates Scientific Figures (Strict White Background for Report)
    
    set(0, 'DefaultFigureVisible', 'off'); 
    
    %% Fig 1: Nestedness Matrix
    [~, idx_r] = sort(sum(M, 2), 'descend'); 
    [~, idx_c] = sort(sum(M, 1), 'descend');
    M_sorted = M(idx_r, idx_c);
    
    f1 = figure('Position', [100, 100, 1000, 800], 'Color', 'w');
    spy(M_sorted, 'k', 2); % Black dots
    title('Nested Structure of Music Consumption', 'Color', 'k', 'FontSize', 12);
    xlabel('Songs (Sorted by Popularity)', 'Color', 'k');
    ylabel('Countries (Sorted by Diversity)', 'Color', 'k');
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    exportgraphics(f1, fullfile(outDir, 'Nestedness_Matrix.png'), 'Resolution', 300);
    
    %% Fig 2: Degree Distributions
    song_degree = sum(M, 1);
    country_degree = sum(M, 2);
    
    f2 = figure('Position', [100, 100, 1200, 500], 'Color', 'w');
    
    subplot(1, 2, 1);
    histogram(country_degree, 20, 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'k');
    title('Country Diversity Distribution (K_{c,0})', 'Color', 'k');
    xlabel('Number of Significant Songs', 'Color', 'k'); 
    ylabel('Frequency', 'Color', 'k');
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    grid on;
    
    subplot(1, 2, 2);
    [counts, edges] = histcounts(song_degree, 50);
    centers = (edges(1:end-1) + edges(2:end)) / 2;
    loglog(centers, counts, 'o-', 'LineWidth', 1.5, 'MarkerFaceColor', 'r', 'Color', 'b');
    title('Song Ubiquity Distribution (K_{p,0})', 'Color', 'k');
    xlabel('Log(Number of Countries)', 'Color', 'k'); 
    ylabel('Log(Frequency)', 'Color', 'k');
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    grid on;
    
    exportgraphics(f2, fullfile(outDir, 'Degree_Distributions.png'), 'Resolution', 300);
    
    %% Fig 3: Complexity Plane
    diversity = Kc(:, 1);       
    avg_ubiquity = Kc(:, 2);    
    
    f3 = figure('Position', [100, 100, 1000, 700], 'Color', 'w');
    scatter(diversity, avg_ubiquity, 80, 'filled', 'MarkerFaceAlpha', 0.7, 'MarkerEdgeColor', 'k');
    text(diversity, avg_ubiquity, regions, 'FontSize', 9, 'VerticalAlignment', 'bottom', 'Color', 'k');
    title('The Music Complexity Plane', 'Color', 'k');
    xlabel('Musical Diversity (K_{c,0})', 'Color', 'k');
    ylabel('Avg. Ubiquity of Playlist (K_{c,1})', 'Color', 'k');
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    grid on;
    xline(mean(diversity), '--r');
    yline(mean(avg_ubiquity), '--r');
    exportgraphics(f3, fullfile(outDir, 'Complexity_Plane.png'), 'Resolution', 300);
    
    %% Fig 4: Complexity Evolution (FIXED LEGEND)
    f4 = figure('Position', [100, 100, 1000, 600], 'Color', 'w');
    [~, rank_idx] = sort(Kc(:, end), 'descend');
    top5 = rank_idx(1:5);
    bot5 = rank_idx(end-4:end);
    
    hold on;
    plot(0:17, Kc(top5, :)', '-o', 'LineWidth', 2);
    plot(0:17, Kc(bot5, :)', '--x', 'LineWidth', 1.5); 
    
    title('Evolution of Country Complexity Scores (K_{c,N})', 'Color', 'k');
    xlabel('Iteration (N)', 'Color', 'k'); 
    ylabel('Complexity Score (Normalized)', 'Color', 'k');
    
    % --- LEGEND FIX: White Box, Black Text ---
    lgd = legend(regions([top5; bot5]), 'Location', 'eastoutside');
    set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');
    
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    grid on;
    exportgraphics(f4, fullfile(outDir, 'Complexity_Evolution.png'), 'Resolution', 300);
    
    %% Fig 5: Network Projection
    threshold = prctile(Sim_Countries(:), 95); 
    Adj = Sim_Countries .* (Sim_Countries > threshold);
    G = graph(Adj, cellstr(regions), 'omitselfloops');
    deg = degree(G);
    G = subgraph(G, deg > 0);
    
    f5 = figure('Position', [100, 100, 1200, 800], 'Color', 'w');
    p = plot(G, 'Layout', 'force', 'WeightEffect', 'direct');
    p.NodeCData = degree(G);
    p.MarkerSize = 7;
    p.EdgeColor = [0.6 0.6 0.6]; 
    p.NodeLabelColor = 'k';
    
    c = colorbar;
    c.Color = 'k';
    c.Label.String = 'Degree Centrality';
    
    title('The "Music Consumption Space" (Country Clusters)', 'Color', 'k');
    set(gca, 'Color', 'w', 'Visible', 'off'); 
    exportgraphics(f5, fullfile(outDir, 'Network_Projection.png'), 'Resolution', 300);
    
    %% Fig 6: Null Model Validation
    f6 = figure('Position', [100, 100, 1000, 500], 'Color', 'w');
    [sorted_z, ~] = sort(Z_Scores, 'descend');
    
    bar(sorted_z(1:50), 'FaceColor', [0.2 0.2 0.2]); 
    yline(2, '--r', 'Z=2 (95% Significance)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    
    title('Statistical Significance of Song Ubiquity (Top 50)', 'Color', 'k');
    xlabel('Song Rank', 'Color', 'k'); 
    ylabel('Z-Score (vs Random Network)', 'Color', 'k');
    set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'FontSize', 10);
    grid on;
    exportgraphics(f6, fullfile(outDir, 'Null_Model_Validation.png'), 'Resolution', 300);
    
    %% Fig 7: Top Complex Songs
    [sorted_kp, song_rank] = sort(Kp(:, end), 'descend'); 
    top_songs = song_rank(1:20);
    
    f7 = figure('Position', [100, 100, 1000, 800], 'Color', 'w');
    barh(flipud(sorted_kp(1:20)), 'FaceColor', [0.1 0.4 0.8]);
    
    yticks(1:20);
    yticklabels(flipud(songs(top_songs)));
    
    ax = gca;
    ax.XColor = 'k'; ax.YColor = 'k'; ax.Color = 'w'; ax.FontSize = 10;
    set(ax, 'Position', [0.45 0.1 0.5 0.8]); % Fix margins for text
    
    title('Most "Complex" Songs', 'Color', 'k');
    xlabel('Complexity Score (K_{p,18})', 'Color', 'k');
    grid on;
    exportgraphics(f7, fullfile(outDir, 'Top_Complex_Songs.png'), 'Resolution', 300);
    
    fprintf('[DONE] Report Figures saved (High Res, White Background).\n');
end