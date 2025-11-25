function visualize_bipartite_network(M, regions, songs, outDir)
    % Visualizes the Bipartite Graph (Node-Link Diagram)
    % Filters for the "Core" of the network to ensure readability.
    
    fprintf('[VIZ] Generating Bipartite Node-Link Diagram...\n');
    
    % 1. Filter for the "Core" (Top Connected Nodes)
    % We can't plot 30k songs. We plot the Top 20 Countries + Top 40 Songs.
    
    n_countries = 20;
    n_songs = 40;
    
    % Sort by Degree (Number of connections)
    deg_r = sum(M, 2);
    deg_s = sum(M, 1);
    
    [~, idx_r] = sort(deg_r, 'descend');
    [~, idx_s] = sort(deg_s, 'descend');
    
    top_r = idx_r(1:n_countries);
    top_s = idx_s(1:n_songs);
    
    % Extract Submatrix
    M_sub = M(top_r, top_s);
    sub_regions = regions(top_r);
    sub_songs = songs(top_s);
    
    % 2. Build Graph Object for Plotting
    % Create adjacency matrix for the plot:
    % [ 0   M ]
    % [ M'  0 ]
    
    num_nodes = n_countries + n_songs;
    Adj = zeros(num_nodes);
    Adj(1:n_countries, n_countries+1:end) = M_sub;
    Adj(n_countries+1:end, 1:n_countries) = M_sub';
    
    % Node Names
    node_names = [sub_regions; sub_songs];
    
    G = graph(Adj, cellstr(node_names));
    
    % 3. Plotting
    f = figure('Position', [100, 100, 1200, 800]);
    
    % Use a Bipartite Layout
    % X coords: Countries = 1, Songs = 2
    % Y coords: Spaced evenly
    x_coords = [ones(n_countries, 1); 2 * ones(n_songs, 1)];
    y_coords = [linspace(0, 1, n_countries)'; linspace(0, 1, n_songs)'];
    
    p = plot(G, 'XData', x_coords, 'YData', y_coords);
    
    % Styling
    p.NodeLabel = node_names;
    p.NodeFontSize = 8;
    p.MarkerSize = 6;
    p.EdgeColor = [0.8, 0.8, 0.8]; % Light gray edges
    p.LineWidth = 0.5;
    
    % Color Nodes by Type
    % Countries = Blue, Songs = Red
    p.NodeColor = [repmat([0 0.4470 0.7410], n_countries, 1); ... % Blue
                   repmat([0.8500 0.3250 0.0980], n_songs, 1)];   % Red
               
    % Remove axis ticks for clean look
    axis off;
    
    % Add Legend manually (since graph plots don't support standard legend easily)
    hold on;
    scatter([], [], 50, [0 0.4470 0.7410], 'filled', 'DisplayName', 'Countries');
    scatter([], [], 50, [0.8500 0.3250 0.0980], 'filled', 'DisplayName', 'Songs');
    legend('Location', 'northeast');
    
    title('The "Core" Bipartite Network Structure');
    subtitle(sprintf('Showing Top %d Countries and Top %d Songs (by Connectivity)', n_countries, n_songs));
    
    saveas(f, fullfile(outDir, 'Bipartite_Graph.png'));
    fprintf('[DONE] Bipartite graph saved.\n');
end