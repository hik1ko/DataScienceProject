function T_clean = data_processing(filepath, targetYear)
    % Reads CSV, filters for year, creates SongIDs, and Aggregates streams
    
    % 1. Detect Import Options
    opts = detectImportOptions(filepath);
    
    % 2. Correctly set Variable Types using 'setvartype'
    opts = setvartype(opts, 'streams', 'double');
    
    % Check if 'date' exists in the file, set type if possible
    if any(strcmpi(opts.VariableNames, 'date'))
        opts = setvartype(opts, 'date', 'datetime');
        opts = setvaropts(opts, 'date', 'InputFormat', 'yyyy-MM-dd'); % Enforce format if needed
    end
    
    % 3. Read Table
    rawT = readtable(filepath, opts);
    
    % 4. Filter Year
    if ~isdatetime(rawT.date)
        rawT.date = datetime(rawT.date, 'InputFormat', 'yyyy-MM-dd');
    end
    
    rawT = rawT(year(rawT.date) == targetYear, :);
    
    % 5. Remove "Global" region
    rawT = rawT(~strcmpi(rawT.region, 'Global'), :);
    
    % 6. Create Unique Song ID (Artist - Title)
    rawT.SongID = strcat(rawT.artist, " - ", rawT.title);
    
    % 7. Aggregate streams (sum) over the whole year per region
    % We group by Region and SongID to get the total yearly streams
    T_clean = groupsummary(rawT, {'region', 'SongID'}, 'sum', 'streams');
    
    % Rename the resulting sum column back to 'Streams'
    T_clean.Properties.VariableNames{'sum_streams'} = 'Streams';
end