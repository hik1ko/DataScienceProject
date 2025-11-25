% Main pipeline for Spotify Network Analysis
clear; close all; clc;

addpath(genpath('src'));
addpath(genpath('utils'));
addpath(genpath('data'));

% Output directory
outputDir = 'output';
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

% Flags: Set to 'true' to force re-calculation of that step
% Set 'viz' to false if you want to generate plots
FORCE_RUN = struct(...
    'data_proc', false, ...
    'bipartite', false, ...
    'rca',       false, ...
    'reflect',   false, ... 
    'project',   true, ...
    'metrics',   false, ...
    'null',      false, ... 
    'viz',       false ...  % If false, it RUNS the visualization
);

%% Data Processing
% -------------------------------------------------------------------------
processedFile = fullfile(outputDir, 'processed_data.mat');
if exist(processedFile, 'file') && ~FORCE_RUN.data_proc
    load(processedFile, 'T_clean');
else
    T_clean = data_processing('data/charts.csv', 2021); 
    save(processedFile, 'T_clean');
end

%% Build Bipartite Adjacency (Raw Matrix X)
% -------------------------------------------------------------------------
adjFile = fullfile(outputDir, 'adjacency.mat');
if exist(adjFile, 'file') && ~FORCE_RUN.bipartite
    load(adjFile, 'X', 'regions', 'songs');
else
    [X, regions, songs] = build_bipartite(T_clean);
    save(adjFile, 'X', 'regions', 'songs');
end

%% Compute RCA & Binary Matrix M
% -------------------------------------------------------------------------
rcaFile = fullfile(outputDir, 'rca_matrix.mat');
if exist(rcaFile, 'file') && ~FORCE_RUN.rca
    load(rcaFile, 'RCA', 'M');
else
    [RCA, M] = compute_rca(X);
    save(rcaFile, 'RCA', 'M');
end

%% Method of Reflections (Complexity Analysis)
% -------------------------------------------------------------------------
reflectFile = fullfile(outputDir, 'complexity_metrics.mat');
if exist(reflectFile, 'file') && ~FORCE_RUN.reflect
    load(reflectFile, 'Kc', 'Kp', 'Country_Complexity_Rank');
else
    [Kc, Kp] = method_of_reflections(M, 18); % 18 iterations
    
    % Create Ranking Table
    [~, sortIdx] = sort(Kc(:,end), 'descend');
    Country_Complexity_Rank = table(regions(sortIdx), Kc(sortIdx,end), ...
        'VariableNames', {'Region', 'Complexity_Index'});
        
    save(reflectFile, 'Kc', 'Kp', 'Country_Complexity_Rank');
end

%% Network Projections (The "Music Space")
% -------------------------------------------------------------------------
projFile = fullfile(outputDir, 'projections.mat');

if exist(projFile, 'file') && ~FORCE_RUN.project
    fprintf('[LOAD] Loading Network Projections...\n');
    vars = who('-file', projFile);
    if ismember('Sim_Countries', vars)
        load(projFile, 'Sim_Countries', 'Sim_Songs');
    else
        fprintf('   [WARN] Old projection format detected. Re-calculating...\n');
        [Sim_Countries, Sim_Songs] = build_projections(M);
        save(projFile, 'Sim_Countries', 'Sim_Songs');
    end
else
    fprintf('[RUN] Calculating Network Projections (Similarity)...\n');
    % Ensures we call the new function with 2 outputs
    [Sim_Countries, Sim_Songs] = build_projections(M);
    save(projFile, 'Sim_Countries', 'Sim_Songs');
end

%% Null Model Validation (Z-Scores)
% -------------------------------------------------------------------------
nullFile = fullfile(outputDir, 'null_models.mat');
if exist(nullFile, 'file') && ~FORCE_RUN.null
    load(nullFile, 'Z_Scores');
else
    Z_Scores = null_model_analysis(M, 100); % 100 randomizations
    save(nullFile, 'Z_Scores');
end

%% -------------------------------------------------------------------------
%  VISUALIZATION & ANALYSIS (Generates Figures for Report)
% -------------------------------------------------------------------------
vizDir = fullfile(outputDir, 'plots');
if ~exist(vizDir, 'dir'), mkdir(vizDir); end

if ~FORCE_RUN.viz
    fprintf('\n--- Starting Visualization Phase ---\n');
    
    % Ensure all variables are loaded (in case previous steps were skipped)
    if ~exist('M','var'), load(rcaFile, 'M'); end
    if ~exist('Kc','var'), load(reflectFile, 'Kc', 'Kp'); end
    if ~exist('Sim_Countries','var'), load(projFile, 'Sim_Countries'); end
    if ~exist('Z_Scores','var'), load(nullFile, 'Z_Scores'); end
    if ~exist('regions','var'), load(adjFile, 'regions', 'songs'); end

    %% Core Report Figures (Figs 1-7)
    fprintf('Generating Standard Report Figures\n');
    visualize_results(M, Kc, Kp, Z_Scores, Sim_Countries, regions, songs, vizDir);

    %% Geo-Spatial Visualization (Fig 8)
    fprintf('Generating Geo-Network Map\n');
    visualize_geo_network(Sim_Countries, Kc, regions, 'data', vizDir);

    %% Community Detection (Fig 9)
    fprintf('Analyzing Communities\n');
    analyze_communities(Sim_Countries, regions, vizDir);

    %% Motif Analysis (Fig 11)
    fprintf('Analyzing Motifs\n');
    analyze_motifs(M, regions, vizDir); % Corrected: Added 'regions'

    %% Bipartite Graph Visualization (Fig 12)
    fprintf('[VIZ] Plotting Bipartite Graph...\n');
    % Calls src/visualize_bipartite_network.m
    visualize_bipartite_network(M, regions, songs, vizDir);

    %% Recommender System Demo
    
    % 3 countries from different expected clusters
    target_countries = {'Vietnam', 'France', 'Brazil'}; 
    
    for i = 1:length(target_countries)
        ctry = target_countries{i};
        if ismember(ctry, regions)
            run_recommender(M, Sim_Countries, regions, songs, ctry, vizDir);
        else
            fprintf('   [SKIP] %s not found in dataset.\n', ctry);
        end
    end
end
