function analyze_motifs(M, regions, outDir)
    fprintf('[VIZ] Generating Motif Heatmap...\n');
    
    V_shared = M * M'; 
    V_plot = V_shared - diag(diag(V_shared));
    
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
    
    f = figure('Position', [100, 100, 900, 800], 'Color', 'w');
    
    [~, idx] = sort(sum(V_plot), 'descend');
    Sorted_Mat = V_plot(idx, idx);
    Sorted_Regions = regions(idx);
    
    imagesc(Sorted_Mat);
    colormap('hot'); 
    c = colorbar;
    c.Label.String = 'Shared Songs';
    c.Color = 'k';
    
    if length(regions) > 50
        fontsize = 6;
    else
        fontsize = 8;
    end
    
    ax = gca;
    ax.Color = 'w';
    ax.XColor = 'k'; ax.YColor = 'k';
    ax.FontSize = fontsize;
    
    xticks(1:length(Sorted_Regions));
    yticks(1:length(Sorted_Regions));
    xticklabels(Sorted_Regions);
    yticklabels(Sorted_Regions);
    xtickangle(90);
    
    title('Motif Density (Shared Song Co-occurrence)', 'Color', 'k');
    xlabel('Country', 'Color', 'k'); ylabel('Country', 'Color', 'k');
    
    exportgraphics(f, fullfile(outDir, 'Motif_Heatmap.png'), 'Resolution', 300);
    
    fid = fopen(fullfile(outDir, 'motif_stats.txt'), 'w');
    fprintf(fid, 'Total 2x2 Bicliques: %d\n', num_butterflies);
    fclose(fid);
    
    fprintf('[DONE] Motif analysis saved.\n');
end