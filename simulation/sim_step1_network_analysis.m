% This code runs the modularity analysis for the simulated adjacency matrices

% add the modularity function from BCT to the path
% BCT modules is downloaded from https://sites.google.com/site/bctnet/
% https://doi.org/10.1016/j.neuroimage.2009.10.003
addpath('/BCT/2019_03_03_BCT')
parpool(32,'IdleTimeout',Inf)
n_rep = 1;
n_usr = 10000;
n_iter = 1000;
gamma = 1;

% modularity is our measure of segregation
modularity = cell(n_iter);
% mean connectivity is our measure of integration
mean_connectivity = cell(n_iter);

%% parfor for each iteration
parfor iter = 1:n_iter
    disp(iter);

    % load the adjacency matrix
    fname = strcat('/data/simulation/networks_sim/simulated_{broadcast/viral}_'...
        ,int2str(iter-1),'.mat');
    disp(fname);
    disp('loading the network data');
    data = load(fname);
    snetwork = data.network;
    disp('loading the network data - success')
    
    fprintf('now load the snetwork for sim-%d \n',iter);
    
    % preprocessing the adjancency to make it as positive and remove the diagonal
    snetwork = snetwork.*(snetwork>0);
    snetwork = snetwork - diag(diag(snetwork));
    
    % initializing the result variable
    modularity_iter = 0;
    mean_connectivity_iter = 0;
    
%% community detection
    fprintf('running modularity  - sim - %d \n', iter);

    q = 0;

    [tem_module, Qt] = community_louvain(snetwork, gamma, []);
    
    q = Qt;
        
    modularity_iter = q;
    mean_connectivity_iter = mean(mean(snetwork));
    
    % save the modularity and mean_connectivity into the cell variable
    modularity{iter} = modularity_iter;
    mean_connectivity{iter} = mean_connectivity_iter;
end

% save the result and store it as a mat file
save('/data/simulation/derivative_{broadcast/viral}_sim_beta02_alpha01.mat', 'modularity', 'mean_connectivity')