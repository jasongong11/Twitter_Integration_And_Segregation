% add modularity analysis file to the path
% BCT modules is downloaded from https://sites.google.com/site/bctnet/
% https://doi.org/10.1016/j.neuroimage.2009.10.003
addpath('/BCT/2019_03_03_BCT')
% set parpool to to parallel processing
n_workers = 32; % define the number of workers
parpool(n_workers,'IdleTimeout',Inf)
% number of louvain algorithm repetition
n_rep = 100;
n_week = 52;
gamma = 1;

% modularity is our measure of segregation
modularity = cell(n_week,1);
% mean_connectivity is our measure of integration
mean_connectivity = cell(n_week,1);

% define the global thretholding
% it will range from 0-0.9
global_thresthold = 0;

%% parfor for each week
parfor week = 1:n_week
    
    % load the adjacency matrix
    disp(week);
    fname = strcat('/data/snetworks/snetwork_week'...
        ,int2str(week-1),'.mat');
    disp(fname);
    disp('loading the network data');
    % load the adjancency matrix
    data = load(fname);
    snetwork = data.snetwork;
    n_usr = size(snetwork,1)
    disp(n_usr)

    disp('loading the network data - success')
    
    fprintf('now load the snetwork for week-%d \n',week)
    
    % preprocessing remove the diagnal and negative edges
    snetwork = snetwork - diag(diag(snetwork));
    snetwork = snetwork.*(snetwork>0);

    % initialize the result variable
    modularity_week = zeros(n_rep, 1);
    mean_connectivity_week = 0;
    
    Q_vec = zeros(n_rep,1);

%% applying global threstholding
    threth = quantile(snetwork(:), global_thresthold); 
    snetwork_thres = snetwork .* (snetwork > threth);

%% applying the backbone extraction - disparity filtering algorithm
    w_null = zeros(n_usr,n_usr);
    for j=1:length(snetwork) % column
        w_null(:,j)=snetwork(:,j)/sum(snetwork(:,j)); % compute the node strength for each 
    end

    % find the index of the upper triangular matrix, because we only need to do the calculation for half of the matrix
    ind_upper=find(triu(ones(length(snetwork),length(snetwork)),1));
    % K_vec is the degree vectors
    K_vec = int16(sum(snetwork));
    

    w_thresh=snetwork;                 % Initialize the w_thresh every time
    for j=1:length(ind_upper)
        % convert the index of the upper triagular matrix back to the index of the full matrix (ii, jj)
        [ii,jj]=ind2sub(size(snetwork),ind_upper(j));
        if (1-w_null(ii,jj))^(K_vec(ii))>0.05 && (1-w_null(jj,ii))^(K_vec(jj))>0.05
            w_thresh(ii,jj)=0; w_thresh(jj,ii)=0;
        end
    end

    disp('finished disparity filtering')
%% community detection
    disp('running modularity');

    fprintf('running modularity - week - %d \n', week);

    q = 0;

    modules_static = zeros(n_usr, 1);

    Qb = 0;
    Q_vec = zeros(n_rep,1);
    for rep = 1: n_rep
	% [tem_module, Qt] = community_louvian(snetwork_thres, 1, []); % running the community detection for the global threstholded matrix
        [tem_module, Qt] = community_louvain(w_thresh, 1, []); % running the community detection for the backbone threstholded matrix
        Q_vec(rep) = Qt;
        if Qt > Qb
             Qb = Qt;
             modules_static = tem_module;
        end
        q = Qb;
    end
        
    fprintf('saving derivatives - - week - %d \n', week);
    % store segregation for all 100 repetition
    modularity_week = Q_vec;
    % calculate integration
    mean_connectivity_week = mean(mean(w_thresh));
    
    modularity{week} = modularity_week;
    mean_connectivity{week} = mean_connectivity_week;
end

% save the result as a mat file
save('/data/derivatives/derivatives_boto_thresthold.mat',...
        'modularity', 'mean_connectivity')

    
    
    

