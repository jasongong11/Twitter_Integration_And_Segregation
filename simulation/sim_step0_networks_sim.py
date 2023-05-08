import networkx as nx
import matplotlib.pyplot as plt
import numpy as np
import ndlib.models.ModelConfig as mc
import ndlib.models.epidemics as ep
from scipy.stats import uniform
from sklearn.metrics.pairwise import cosine_similarity
from scipy import io

# specifying the beta and alpha
beta = 0.2
alpha = 0.1

# define the initial conditions for viral spreading
def update_profiles_viral(node_vectors, alpha, initial_node, infected_nodes):
    # make a copy of the old semantic embeddings of all nodes before infection
    node_vectors_update = node_vectors.copy()

    # extract the semantic embeddings of source node
    initial_node_vector = node_vectors_update[initial_node,:]
    
    # simulate the influence of source on the infected nodes
    # specify amount of influence
    node_vectors_update[infected_nodes,:] = node_vectors_update[infected_nodes,:] + \
    alpha * (initial_node_vector - node_vectors_update[infected_nodes,:])
    
    # return the updated semantic embeddings for all nodes after infection
    return(node_vectors_update)

# define the initial conditions for broadcast spreading
def update_profiles_broadcasting(node_vectors, alpha, initial_node, infected_nodes_length):
    # make a copy of the old semantic embeddings of all nodes before infection
    node_vectors_update = node_vectors.copy()

    # simulate global contagion based on random nodes
    # this is constrained by the size of casecading tree of the viral spreading
    infected_nodes = np.random.choice(node_vectors.shape[0],infected_nodes_length)
    # extract the semantic features of source node
    initial_node_vector = node_vectors_update[initial_node,:]
    
    # simulate the influence of source on the infected nodes
    # specify amount of influence
    node_vectors_update[infected_nodes,:] = node_vectors_update[infected_nodes,:] + \
    alpha * (initial_node_vector - node_vectors_update[infected_nodes,:])
    
    # return the updated semantic embeddings for all nodes after infection
    return(node_vectors_update)

# this function extracts the initial nodes from the cascading trees
def get_key(val, my_dict):
    for key, value in my_dict.items():
         if val == value:
             return key

# this function extracts the infected nodes from the cascading trees      
def get_infected_nodes(iterations):
    temp_list = [list(iterations[i]['status'].keys()) for i in range(1,len(iterations))]
    return(list(set(sum(temp_list, []))))

# define the social network to be a random scale-free graph
g = nx.scale_free_graph(10000, seed=123)

## The next block of codes defines the infection source and infected nodes
n_nodes_list = []
nodes_cascade_list = []
nodes_infected_list = []

# simulation 1000 spreading events
# to make sure that we have at least 1000 events
# here the number of iterations are set to be 1200
while len(n_nodes_list) <= 1200:
    print('simulate diffusion trees - iteration - {}'.format(len(n_nodes_list)))

    # initiate the SI model
    model = ep.SIModel(g)

    # Model Configuration
    cfg = mc.Configuration()
    cfg.add_model_parameter('beta', beta)
    cfg.add_model_parameter("fraction_infected", 1/10000)
    model.set_initial_status(cfg)
    
    # Simulation execution
    # set the depth of cascades to be up to 4 (source node is counted as one layer so here is 5)
    iterations = model.iteration_bunch(5)
    
    # obtain list of nodes being infected
    node_infected = get_infected_nodes(iterations)    
    if 1 <= len(node_infected):
        n_nodes_list.append(len(node_infected))
        nodes_cascade_list.append(iterations)
        nodes_infected_list.append(np.array(node_infected))   

# get the list of source nodes
initial_node_list = []
for i in range(len(n_nodes_list)):
    initial_node = get_key(1, nodes_cascade_list[i][0]['status'])
    initial_node_list.append(initial_node)

## the semantic embeddings begin to be updated based on infection
print("length of cascades:")
print(len(initial_node_list))
np.random.seed(123)

# initiate the nodes embeddings to be random vectors
node_vectors = np.random.rand(10000, 100)
# obtain the adjacency matrix of the simulated discourse network
sim_mat = cosine_similarity(node_vectors)
print(np.mean(sim_mat))
print(sim_mat.shape)

# start the simulation of social influence - viral spreading
node_vectors_update = node_vectors.copy()
mean_sim_list_v = []
for i in range(1000):
    print('simulate viral spreading iteration - {}'.format(i))
    
    # extract the source node and the nodes infected
    initial_node = initial_node_list[i]
    infected_nodes = nodes_infected_list[i]
    
    # for each iteration, we update the infected nodes to be
    # the weighted average of the infected nodes and the source nodes
    node_vectors_update = update_profiles_viral(node_vectors_update, alpha, initial_node, infected_nodes)
    # obtain the adjacency matrix after each iteration
    sim_mat_updated = cosine_similarity(node_vectors_update)
    # save the adjacency matrix after each iteration
    io.savemat('/data/simulation/networks_sim/viral_{}.mat'.format(i),
            {'network': sim_mat_updated})


# start the simulation of social influence - broadcast spreading
node_vectors_update = node_vectors.copy()
mean_sim_list_b = []
for i in range(1000):
    print('simulate broadcast spreading iteration - {}'.format(i))

    # extract the source node and the size of cascading tree 
    initial_node = initial_node_list[i]
    infected_nodes = nodes_infected_list[i]
    infected_nodes_length = len(infected_nodes)

    # for each iteration, we update the infected nodes to be
    # the weighted average of the infected nodes and the source nodes
    node_vectors_update = update_profiles_broadcasting(node_vectors_update, alpha, initial_node, infected_nodes_length)
    # obtain the adjacency matrix after each iteration
    sim_mat_updated = cosine_similarity(node_vectors_update)
    # save the adjacency matrix after each iteration
    io.savemat('/data/simulation/networks_sim/broadcast_{}.mat'.format(i), 
            {'network': sim_mat_updated})
    