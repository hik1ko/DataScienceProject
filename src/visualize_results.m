function visualize_results(M, Kc, Kp, Z_Scores, Sim_Countries, regions, songs, outDir)
    % Generates Scientific Figures (Clean Titles)
    
    set(0, 'DefaultFigureVisible', 'off'); 
    
    %% Nestedness Matrix
    [~, idx_r] = sort(sum(M, 2), 'descend'); 
    [~, idx_c] = sort(sum(M, 1), 'descend');
    M_sorted = M(idx_r, idx_c);
    
    f1 = figure('Position', [100, 100, 1000, 800]);
    spy(M_sorted, 'k', 2);
    title('Nested Structure of Music Consumption (Sorted Matrix)');
    xlabel('Songs (Sorted by Popularity)');
    ylabel('Countries (Sorted by Diversity)');
    saveas(f1, fullfile(outDir, 'Nestedness_Matrix.png'));
    
    %% Degree Distributions
    song_degree = sum(M, 1);
    country_degree = sum(M, 2);
    
    f2 = figure('Position', [100, 100, 1200, 500]);
    subplot(1, 2, 1);
    histogram(country_degree, 20, 'FaceColor', [0 0.4470 0.7410]);
    title('Country Diversity Distribution (K_{c,0})');
    xlabel('Number of Significant Songs'); ylabel('Frequency');
    grid on;
    
    subplot(1, 2, 2);
    [counts, edges] = histcounts(song_degree, 50);
    centers = (edges(1:end-1) + edges(2:end)) / 2;
    loglog(centers, counts, 'o-', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
    title('Song Ubiquity Distribution (K_{p,0}) - Log-Log');
    xlabel('Log(Number of Countries)'); ylabel('Log(Frequency)');
    grid on;
    saveas(f2, fullfile(outDir, 'Degree_Distributions.png'));
    
    %% Complexity Plane
    diversity = Kc(:, 1);       
    avg_ubiquity = Kc(:, 2);    
    
    f3 = figure('Position', [100, 100, 1000, 700]);
    scatter(diversity, avg_ubiquity, 80, 'filled', 'MarkerFaceAlpha', 0.6);
    text(diversity, avg_ubiquity, regions, 'FontSize', 8, 'VerticalAlignment', 'bottom');
    title('The Music Complexity Plane');
    xlabel('Musical Diversity (K_{c,0})');
    ylabel('Avg. Ubiquity of Playlist (K_{c,1})');
    grid on;
    xline(mean(diversity), '--r');
    yline(mean(avg_ubiquity), '--r');
    saveas(f3, fullfile(outDir, 'Complexity_Plane.png'));
    
    %% Complexity Evolution
    f4 = figure('Position', [100, 100, 1000, 600]);
    [~, rank_idx] = sort(Kc(:, end), 'descend');
    top5 = rank_idx(1:5);
    bot5 = rank_idx(end-4:end);
    hold on;
    plot(0:17, Kc(top5, :)', '-o', 'LineWidth', 1.5);
    plot(0:17, Kc(bot5, :)', '--x', 'LineWidth', 1); 
    title('Evolution of Country Complexity Scores (K_{c,N})');
    xlabel('Iteration (N)'); ylabel('Complexity Score (Normalized)');
    legend(regions([top5; bot5]), 'Location', 'eastoutside');
    grid on;
    saveas(f4, fullfile(outDir, 'Complexity_Evolution.png'));
    
    %% Network Projection
    threshold = prctile(Sim_Countries(:), 95); 
    Adj = Sim_Countries .* (Sim_Countries > threshold);
    G = graph(Adj, cellstr(regions), 'omitselfloops');
    deg = degree(G);
    G = subgraph(G, deg > 0);
    
    f5 = figure('Position', [100, 100, 1200, 800]);
    p = plot(G, 'Layout', 'force', 'WeightEffect', 'direct');
    p.NodeCData = degree(G);
    p.MarkerSize = 6;
    colorbar;
    title('The "Music Consumption Space" (Country Clusters)');
    subtitle(sprintf('Links represent > 95th percentile similarity (Jaccard)'));
    saveas(f5, fullfile(outDir, 'Network_Projection.png'));
    
    %% Null Model Validation
    f6 = figure('Position', [100, 100, 1000, 500]);
    [sorted_z, z_idx] = sort(Z_Scores, 'descend');
    bar(sorted_z(1:50));
    yline(2, '--r', 'Z=2 (95% Significance)');
    title('Statistical Significance of Song Ubiquity (Top 50)');
    xlabel('Song Rank'); ylabel('Z-Score (vs Random Network)');
    grid on;
    saveas(f6, fullfile(outDir, 'Null_Model_Validation.png'));
    
    %% Top Complex Songs
    [sorted_kp, song_rank] = sort(Kp(:, end), 'descend'); 
    top_songs = song_rank(1:20);
    
    f7 = figure('Position', [100, 100, 800, 600]);
    barh(flipud(sorted_kp(1:20)), 'FaceColor', [0.1 0.6 0.9]);
    yticks(1:20);
    yticklabels(flipud(songs(top_songs)));
    title('Most "Complex" Songs (Listened to by Diversified Countries)');
    xlabel('Complexity Score (K_{p,18})');
    grid on;
    saveas(f7, fullfile(outDir, 'Top_Complex_Songs.png'));
    
    fprintf('[DONE] Report Figures saved.\n');
end