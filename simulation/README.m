# Simulation codes
Simlulation directory includes code to reproduce the simulation model and data analysis.

# sim_step0_networks_sim.py
- simulate the viral and broadcast spreading
- generate the adjacency matrices for each of the spreading events
### dependencies:
- networkx == v2.8.3
- python == v3.7
- ndlib == v5.1.0
- sklearn == v1.1.1

# sim_step1_networks_sim.m
- apply louvian community detection algorithm
- calcualte integration (network density) and segregation (modularity)
- conduct the analysis in parallel using parfor
### dependencies:
- BCT (https://sites.google.com/site/bctnet/)