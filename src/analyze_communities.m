function analyze_communities(Sim_Countries, regions, outDir)
    % Performs Hierarchical Clustering to find "Musical Families" of countries
    % Generates a Dendrogram and a Sorted Matrix View
    
    fprintf('[RUN] analyzing Communities (Hierarchical Clustering)...\n');
    
    % 1. Calculate Distances (1 - Similarity)
    % We use the Jaccard Similarity calculated in the Projections step
    Distances = 1 - Sim_Countries;
    
    % Ensuring symmetric and zero diagonal (numerical precision fix)
    Distances = (Distances + Distances') / 2;
    Distances(1:size(Distances,1)+1:end) = 0;
    
    % Converting to vector format for linkage (upper triangular)
    vec_dist = squareform(Distances);
    
    % 2. Perform Hierarchical Clustering (Ward's Method)
    % Ward's method minimizes variance within clusters
    Z = linkage(vec_dist, 'ward');
    
    % 3. Generate Dendrogram Figure
    f = figure('Position', [100, 100, 1200, 800]);
    
    % Draw Dendrogram with ~30 leaf nodes for readability 
    % (or 0 to show all 68 countries)
    [H, T, Outperm] = dendrogram(Z, 0, 'Labels', cellstr(regions), ...
        'Orientation', 'left', 'ColorThreshold', 'default');
    
    set(H, 'LineWidth', 1.5);
    title('Hierarchical Clustering of Musical Tastes');
    xlabel('Distance (Dissimilarity)');
    ylabel('Country');
    grid on;
    
    % Aesthetics: Fix axis
    ax = gca;
    ax.FontSize = 9;
    
    saveas(f, fullfile(outDir, 'Community_Dendrogram.png'));
    
    % 4. Save Cluster Assignments (e.g., 5 main clusters)
    num_clusters = 5;
    clusters = cluster(Z, 'maxclust', num_clusters);
    
    % Save table for the report appendix
    T_Clusters = table(regions, clusters, 'VariableNames', {'Region', 'ClusterID'});
    writetable(T_Clusters, fullfile(outDir, 'country_clusters.csv'));
    
    fprintf('[DONE] Community analysis saved to %s\n', outDir);
end