function visualize_bipartite_network(M, regions, songs, outDir)
    % Visualizes the Bipartite Graph (Node-Link Diagram)
    
    n_countries = 20; n_songs = 40;
    deg_r = full(sum(M, 2)); deg_s = full(sum(M, 1));
    [~, idx_r] = sort(deg_r, 'descend'); [~, idx_s] = sort(deg_s, 'descend');
    
    top_r = idx_r(1:min(n_countries, length(idx_r))); 
    top_s = idx_s(1:min(n_songs, length(idx_s)));
    M_sub = M(top_r, top_s);
    sub_regions = regions(top_r); sub_songs = songs(top_s);
    
    Adj = zeros(n_countries + n_songs);
    Adj(1:n_countries, n_countries+1:end) = M_sub;
    Adj(n_countries+1:end, 1:n_countries) = M_sub';
    
    G = graph(Adj, cellstr([sub_regions; sub_songs]));
    
    % PLOTTING
    f = figure('Position', [100, 100, 1200, 800], 'Color', 'w'); % White
    
    x_coords = [ones(n_countries, 1); 2 * ones(n_songs, 1)];
    y_coords = [linspace(0, 1, n_countries)'; linspace(0, 1, n_songs)'];
    
    p = plot(G, 'XData', x_coords, 'YData', y_coords);
    
    p.NodeLabel = G.Nodes.Name;
    p.NodeFontSize = 9;
    p.NodeLabelColor = 'k'; % Black Text
    p.MarkerSize = 7;
    p.EdgeColor = [0.7 0.7 0.7]; % Light Gray lines
    p.LineWidth = 0.5;
    
    p.NodeColor = [repmat([0 0.4470 0.7410], n_countries, 1); ... % Blue
                   repmat([0.8500 0.3250 0.0980], n_songs, 1)];   % Red
               
    axis off;
    
    % Legend
    hold on;
    scatter([], [], 50, [0 0.4470 0.7410], 'filled', 'DisplayName', 'Countries');
    scatter([], [], 50, [0.8500 0.3250 0.0980], 'filled', 'DisplayName', 'Songs');
    lgd = legend('Location', 'northeast');
    set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', 'k');
    
    title('The "Core" Bipartite Network Structure', 'Color', 'k', 'FontSize', 14);
    
    exportgraphics(f, fullfile(outDir, 'Bipartite_Graph.png'), 'Resolution', 300);
    fprintf('[DONE] Bipartite graph saved.\n');
end