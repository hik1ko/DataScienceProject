# Network Modeling of Geographical Music Consumption
### A Spotify Case Study for Improved Recommender Systems

![MATLAB](https://img.shields.io/badge/Made_with-MATLAB-orange.svg)
![Network Science](https://img.shields.io/badge/Science-Network_Theory-blue.svg)
![Status](https://img.shields.io/badge/Status-Completed-green.svg)

## 📌 Overview
This project applies the **Economic Complexity framework** (originally developed by Hidalgo & Hausmann for economics) to the domain of **Cultural Consumption**.

By modeling Spotify streaming data as a bipartite network (Countries $\times$ Songs), we move beyond simple popularity metrics. Instead, we analyze the **structural topology** of music consumption to measure the "Musical Sophistication" of nations and the "Niche Appeal" of songs. The ultimate goal is to build a **Recommender System** that suggests songs based on structural community detection rather than generic global trends.

## 🚀 Key Features
* **Bipartite Network Construction:** Maps 68 countries to ~2,300 globally significant songs.
* **RCA Filtering:** Uses **Revealed Comparative Advantage (RCA)** to filter out noise and focus on songs that countries "specialize" in.
* **Complexity Analysis:** Implements the **Method of Reflections** algorithm to calculate $K_{c,N}$ (Country Complexity) and $K_{p,N}$ (Song Complexity) over 18 iterations.
* **Structural Validation:** Uses **Null Models (Z-Scores)** and **Network Motifs** to prove that consumption patterns are statistically significant and non-random.
* **Geospatial Visualization:** custom-built visualization engine to map cultural similarities on a world map.
* **Recommender Engine:** A "Missing Link" prediction system that recommends songs based on a country's location in the "Music Space" (Cluster Analysis).

## 📂 Dataset
**Note: The raw data is not included in this repository due to size constraints.**

To run this project, you must download the dataset manually:
1.  Go to **[Spotify Charts (Kaggle)](https://www.kaggle.com/datasets/dhruvildave/spotify-charts)**.
2.  Download the `charts.csv` file.
3.  Place `charts.csv` inside the `data/` folder of this repository.
4.  *(Optional)* The `country_coords.csv` file (included in this repo) is required for geospatial plotting.

## 🛠️ Project Structure
```text
.
├── main.m                     # The orchestrator script (Run this to start)
├── data/
│   ├── charts.csv             # [YOU MUST ADD THIS FILE]
│   └── country_coords.csv     # Coordinates for geo-plotting
├── src/                       # Core logic modules
│   ├── build_bipartite.m      # Network construction & filtering
│   ├── compute_rca.m          # RCA calculation & Binarization
│   ├── method_of_reflections.m# Complexity algorithm (Hidalgo et al.)
│   ├── analyze_communities.m  # Hierarchical clustering
│   ├── analyze_motifs.m       # Structural motif counting
│   └── run_recommender.m      # Recommendation engine
├── utils/                     # Helper functions
│   ├── fit_powerlaw.m         # Statistical fitting
│   └── null_model_bipartite.m # Randomization for validation
└── output/                    # Generated results (Figures & Metrics)

⚙️ Installation & Usage
Prerequisites
MATLAB (R2021a or later recommended)

Statistics and Machine Learning Toolbox

Mapping Toolbox (for geospatial plots)

Running the Analysis
Clone this repository.

Ensure charts.csv is in the data/ folder.

Open MATLAB and navigate to the project root.

Run main.m.

The script is modular and cached. It will automatically process the data, run the network algorithms, and generate 7+ scientific figures in the output/plots/ directory.

📊 Outputs & Visualization
The pipeline generates high-resolution visualizations including:

The Music Complexity Plane: Ranking countries by diversity vs. ubiquity.

Nestedness Matrix: Visual proof of the non-random structure of music consumption.

Geospatial Similarity Network: A world map connecting countries with statistically similar tastes (ignoring physical distance).

Cluster Dendrograms: Hierarchical trees showing "Musical Families" (e.g., The Latin Cluster, The Nordic Cluster).

📚 References & Theory
This project translates methods from the following papers into the music domain:

Hidalgo, C. A., & Hausmann, R. (2009). The building blocks of economic complexity. PNAS.

Spelta, A., et al. (2025). The complexity of pharmaceutical expenditures. Scientific Reports.

📜 License
This project is open-source under the MIT License.
