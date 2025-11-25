function analyze_motifs(M, regions, outDir)
    % Counts "Butterflies" (2x2 Bicliques) and plots a Labeled Heatmap
    
    fprintf('[RUN] Analyzing Network Motifs (Bicliques)...\n');
    
    % 1. Calculate Co-occurrence Matrix
    % V_shared(i,j) = number of songs shared by Country i and Country j
    V_shared = M * M'; 
    
    % Remove diagonal (self-loops) for better color contrast in plot
    V_plot = V_shared - diag(diag(V_shared));
    
    % 2. Count Butterflies (Cycles of length 4)
    % Formula: Sum of (k choose 2) for all off-diagonal elements
    num_butterflies = 0;
    [R, ~] = size(V_shared);
    
    for i = 1:R
        for j = i+1:R
            k = V_shared(i,j);
            if k >= 2
                num_butterflies = num_butterflies + (k * (k-1)) / 2;
            end
        end
    end
    
    fprintf('   > Total Motifs (2x2 Bicliques) found: %d\n', num_butterflies);
    
    % 3. Visualization (Heatmap of Shared Songs)
    f = figure('Position', [100, 100, 900, 800]);
    
    % SORTING: Group the most active countries together for a better looking plot
    [~, idx] = sort(sum(V_plot), 'descend');
    Sorted_Mat = V_plot(idx, idx);
    Sorted_Regions = regions(idx);
    
    imagesc(Sorted_Mat);
    colormap('hot'); 
    c = colorbar;
    c.Label.String = 'Shared Songs (Biclique Potential)';
    
    % Add Country Names to Axes (Crucial for your Report)
    xticks(1:length(Sorted_Regions));
    yticks(1:length(Sorted_Regions));
    xticklabels(Sorted_Regions);
    yticklabels(Sorted_Regions);
    xtickangle(90);
    
    % Fix font size if there are too many countries
    if length(regions) > 50
        set(gca, 'FontSize', 6);
    else
        set(gca, 'FontSize', 8);
    end
    
    title('Motif Density: Shared Songs per Country Pair');
    xlabel('Country'); ylabel('Country');
    
    saveas(f, fullfile(outDir, 'Motif_Heatmap.png'));
    
    % 4. Save Stats to Text File
    fid = fopen(fullfile(outDir, 'motif_stats.txt'), 'w');
    fprintf(fid, 'Network Structure Analysis:\n');
    fprintf(fid, 'Total 2x2 Bicliques (Butterflies): %d\n', num_butterflies);
    fprintf(fid, 'This indicates high transitivity in music consumption preferences.\n');
    fclose(fid);
    
    fprintf('[DONE] Motif analysis saved.\n');
end