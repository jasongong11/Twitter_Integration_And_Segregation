import scipy.io
import scipy
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import pairwise_distances, cosine_similarity



# for botometer threstholds raning from 0.5 to 1.0
for i in range(5,11):
    # load tf_itf_tsvd_100 numpy array
    # dimension should be nrow = n_week (52) * n_nodes (n users), ncol = n PCA dimensions
    tf_itf_tsvd_100_df = pd.read_csv("/data/data_and_derivatives/tweets_embeddings_boto{}.csv".format(i))
    tf_itf_tsvd_100 = tf_itf_tsvd_100_df.iloc[:,1:].to_numpy()

    # number of nodes is the number of rows of the dataframe divided by 52
    n_sample = int(tf_itf_tsvd_100.shape[0] / 52)
    outputfile = "/data/data_and_derivatives/snetworks_boto{}/".format(i)
    print(outputfile)
    # store adjacency matrix for each week
    for j in range(52):
        print(j*n_sample, j*n_sample+n_sample)
        # construct the adjacency matrix by applying the pairwise cosine similarity
        snetwork = cosine_similarity(tf_itf_tsvd_100[(j*n_sample):(j*n_sample+n_sample), :])
        # save file
        scipy.io.savemat(outputfile+'snetwork_week'+str(j)+'.mat', {"snetwork":snetwork})
