function visualize_geo_network(Sim_Countries, Kc, regions, dataDir, outDir)
    % Visualizes the Musical Similarity Network on a Real World Map
    
    fprintf('[VIZ] Generating Geo-Network Map \n');
    
    % 1. Load Coordinates
    coordFile = fullfile(dataDir, 'country_coords.csv');
    if ~exist(coordFile, 'file')
        warning('country_coords.csv not found. Skipping Geo Plot.');
        return;
    end
    
    Coords = readtable(coordFile, 'TextType', 'string');
    
    % Match regions to coordinates
    num_regions = length(regions);
    Lats = zeros(num_regions, 1);
    Lons = zeros(num_regions, 1);
    valid_mask = false(num_regions, 1);
    
    for i = 1:num_regions
        r_name = strtrim(char(regions(i)));
        switch lower(r_name)
            case 'france',          lat=46.603354; lon=1.888334; found=true;
            case 'usa',             lat=37.0902;   lon=-95.7129; found=true;
            case 'united states',   lat=37.0902;   lon=-95.7129; found=true;
            case 'uk',              lat=55.3781;   lon=-3.4360;  found=true;
            case 'united kingdom',  lat=55.3781;   lon=-3.4360;  found=true;
            case 'russia',          lat=61.5240;   lon=105.3188; found=true;
            case 'chile',           lat=-35.6751;  lon=-71.5430; found=true;
            case 'united arab emirates', lat=23.4241; lon=53.8478; found=true;
            case 'uae',             lat=23.4241;   lon=53.8478;  found=true;
            otherwise
                idx = find(strcmpi(Coords.Region, r_name), 1);
                if ~isempty(idx)
                    lat = Coords.Lat(idx);
                    lon = Coords.Lon(idx);
                    found = true;
                else
                    found = false;
                end
        end
        if found
            Lats(i) = lat; Lons(i) = lon; valid_mask(i) = true;
        end
    end
    
    final_regions = regions(valid_mask);
    final_lats = Lats(valid_mask);
    final_lons = Lons(valid_mask);
    final_Sim = Sim_Countries(valid_mask, valid_mask);
    final_Complexity = Kc(valid_mask, end); 
    
    %% 2. Prepare the Map
    f_geo = figure('Position', [50, 50, 1400, 800], 'Color', 'w');
    
    gx = geoaxes('Basemap', 'grayland'); 
    hold on;
    
    % --- FIX: FORCE BLACK TEXT & SCALE ---
    % 1. Grid/Ticks
    gx.GridColor = 'k';
    gx.GridAlpha = 0.4;
    gx.FontSize = 11; % Make numbers bigger
    
    % 2. Axis Labels (Try/Catch for older MATLAB compatibility)
    try gx.LatitudeLabel.Color = 'k'; catch; end
    try gx.LongitudeLabel.Color = 'k'; catch; end
    try gx.Title.Color = 'k'; catch; end
    
    % 3. Scalebar (The bottom-left ruler)
    try 
        sb = gx.Scalebar;
        sb.Visible = 'on';
        sb.Color = 'k'; % Force Black
    catch
    end
    
    % Force View
    geolimits([-60 85], [-180 180]); 
    drawnow; pause(1); 
    
    title(gx, 'Global Music Similarity Network', 'FontSize', 16, 'Color', 'k', 'FontWeight', 'bold');
    subtitle(gx, 'Nodes: Countries (Color=Complexity) | Lines: Strong Similarity', 'FontSize', 12, 'Color', 'k');
    
    %% 3. Draw Connections
    threshold = prctile(final_Sim(:), 99); 
    [row, col] = find(triu(final_Sim > threshold, 1));
    lat_segments = []; lon_segments = [];
    for k = 1:length(row)
        lat_segments = [lat_segments, final_lats(row(k)), final_lats(col(k)), NaN]; %#ok<AGROW>
        lon_segments = [lon_segments, final_lons(row(k)), final_lons(col(k)), NaN]; %#ok<AGROW>
    end
    geoplot(gx, lat_segments, lon_segments, '-', 'Color', [0, 0.6, 0.6, 0.6], 'LineWidth', 0.8);
    
    %% 4. Draw Countries
    c_score = normalize(final_Complexity, 'range');
    geoscatter(gx, final_lats, final_lons, 80, c_score, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    colormap(gx, 'parula');
    c = colorbar;
    c.Label.String = 'Musical Complexity Score';
    c.Color = 'k'; % Black text on colorbar
    
    %% 5. Labels
    deg = sum(final_Sim, 2);
    [~, sortIdx] = sort(deg, 'descend');
    top_hubs = sortIdx(1:15);
    force_labels = {'France', 'Japan', 'Brazil', 'Turkey', 'Vietnam', 'USA', 'UK'};
    labels_to_plot = top_hubs;
    for k = 1:length(force_labels)
        idx = find(strcmpi(final_regions, force_labels{k}));
        if ~isempty(idx), labels_to_plot = unique([labels_to_plot; idx]); end
    end
    
    text(final_lats(labels_to_plot), final_lons(labels_to_plot), final_regions(labels_to_plot), ...
        'Color', 'black', 'FontSize', 9, 'FontWeight', 'bold', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'Margin', 1, ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    
    %% 6. Save
    exportgraphics(f_geo, fullfile(outDir, 'Geo_Network_Map.png'), 'Resolution', 300);
    fprintf('[DONE] Geo Map saved.\n');
end