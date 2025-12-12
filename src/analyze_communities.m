function analyze_communities(Sim_Countries, regions, outDir)
    fprintf('[VIZ] Generating Community Dendrogram...\n');
    
    Dist = 1 - Sim_Countries;
    Dist = (Dist + Dist') / 2;
    vec_dist = squareform(Dist - diag(diag(Dist)));
    Z = linkage(vec_dist, 'average');
    
    f = figure('Position', [100, 100, 1000, 1200], 'Color', 'w');
    
    [H, ~] = dendrogram(Z, 0, 'Labels', cellstr(regions), ...
        'Orientation', 'left', 'ColorThreshold', 'default');
    
    set(H, 'LineWidth', 1.5, 'Color', 'k'); % Black lines
    
    title('Hierarchical Clustering of Musical Tastes', 'Color', 'k');
    xlabel('Dissimilarity Distance (1 - Jaccard)', 'Color', 'k');
    ylabel('Country', 'Color', 'k');
    
    ax = gca;
    ax.Color = 'w';      % White Inner Background
    ax.XColor = 'k';     % Black Axis
    ax.YColor = 'k';
    ax.FontSize = 10;
    grid on;
    
    exportgraphics(f, fullfile(outDir, 'Community_Dendrogram.png'), 'Resolution', 300);
    
    % Save Cluster Data
    num_clusters = 5;
    clusters = cluster(Z, 'maxclust', num_clusters);
    T_Clusters = table(regions, clusters, 'VariableNames', {'Region', 'ClusterID'});
    writetable(T_Clusters, fullfile(outDir, 'country_clusters.csv'));
    
    fprintf('[DONE] Community analysis saved.\n');
end