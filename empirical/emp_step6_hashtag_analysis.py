import re
from sklearn.feature_extraction.text import CountVectorizer
countVectorizer = CountVectorizer()
import numpy as np
import pandas as pd
from collections import OrderedDict
import scipy

# this function is to extract the hashtags from tweets
def extract_hastags(text):
    return ' '.join(re.findall(r"#(\w+)", text))

# this function is to calculate the gini coefficient from a given numpy array
def gini(array):
    """Calculate the Gini coefficient of a numpy array."""
    # based on bottom eq:
    # http://www.statsdirect.com/help/generatedimages/equations/equation154.svg
    # from:
    # http://www.statsdirect.com/help/default.htm#nonparametric_methods/gini.htm
    # All values are treated equally, arrays must be 1d:
    array = array.astype('float').flatten()
    if np.amin(array) < 0:
        # Values cannot be negative:
        array -= np.amin(array)
    # Values cannot be 0:
    array += 0.0000001
    # Values must be sorted:
    array = np.sort(array)
    # Index per array element:
    index = np.arange(1,array.shape[0]+1)
    # Number of array elements:
    n = array.shape[0]
    # Gini coefficient:
    return ((np.sum((2 * index - n  - 1) * array)) / (n * np.sum(array)))


# read the tweets dataframe that is grouped by users and weeks
filename = "/data/data_and_derivatives/user_tweets_df_groupby_boto.csv"
tweets_df_group_by = pd.read_csv(filename)

# apply the hashtag extraction and store it as a column
tweets_df_group_by['hashtags_list'] = tweets_df_group_by['text'].apply(extract_hastags)
# define the hashtag dataframe which stores the hashtags for each week
hash_tags_df = tweets_df_group_by.groupby('created_at').hashtags_list.apply(' '.join).reset_index()

# transform the hashtag dataframe into a counter matrix
hashtag_count_matrix = countVectorizer.fit_transform(hash_tags_df.hashtags_list)
# get the number of each hashtags
num_hash_tags = hashtag_count_matrix.sum(axis=0).tolist()[0]
# get the name of each hashtags ranked by its counts
hash_tags = countVectorizer.get_feature_names()

# convert the hashtag counts as a ordered dictionary
num_hash_tags_dict = dict(zip(hash_tags, num_hash_tags))
num_hash_tags_dict = OrderedDict(dict(sorted(num_hash_tags_dict.items(), key=lambda item: item[1], reverse = True)))

# get the top 100 hashtags
top_100_hash_tags = list(num_hash_tags_dict.keys())[:100]

# create the counter matrix for the top 100 hashtags
top_100_tag_counts = []
for tag in top_100_hash_tags:
    top_100_tag_counts.append(hashtag_count_matrix[:, hash_tags.index(tag)].todense().T)
top_100_tag_counts_matrix = np.vstack(top_100_tag_counts)


# calculate the gini coefficient for each hashtag
gini_list = []
for i in range(hashtag_count_matrix.shape[0]):
    test = top_100_tag_counts_matrix.T[i,:]
    test = np.squeeze(np.asarray(test))
    gini_list.append(gini(test))

# get the index of the weeks for the peaks of each hashtag
top_tag_counts_matrix = top_100_tag_counts_matrix
max_index = np.argmax(top_tag_counts_matrix, axis=1).flatten()

# calculate the vbi using the log(after/pre)
pre_list = []
after_list= []
after_pre_list = []
for i in range(top_tag_counts_matrix.shape[0]):
    # calculate the number of hashtags pre peak
    pre = np.sum(top_tag_counts_matrix[i,0:max_index[0,i]])
    # calculate the number of hashtags after peak
    after = np.sum(top_tag_counts_matrix[i,(max_index[0,i]):])
    
    # calculate the ratio of after/pre
    after_pre = after/pre

    pre_list.append(pre)
    after_list.append(after)
    after_pre_list.append(after_pre)

# calculate the weight for each hashtags in each week
# this weight is the percentage of each hashtag in each week
precentage_counts_matrix = (top_tag_counts_matrix.T/np.sum(top_tag_counts_matrix.T,axis=1)).T
# because the log(after/pre) will generate inifity values
# we need to drop these values, so we obtain the index for infinity hashtags
drop_index = np.isinf(np.log(after_pre_list))
# calculate the week vbi by the weighted sum of hashtag vbis
after_pre_week = precentage_counts_matrix[~drop_index,:].T.dot(np.log(after_pre_list)[~drop_index])
viral_broacast_1 = after_pre_week

# calculate the vbi using the after/(pre+after)
pre_list = []
after_list= []
after_pre_list = []
for i in range(top_tag_counts_matrix.shape[0]):
    # calculate the number of hashtags pre peak
    pre = np.sum(top_tag_counts_matrix[i,0:max_index[0,i]])
    # calculate the number of hashtags after peak
    after = np.sum(top_tag_counts_matrix[i,(max_index[0,i]):])
    # calculate the percentage of after over total
    after_pre = after/(after+pre)
    
    pre_list.append(pre)
    after_list.append(after)
    after_pre_list.append(after_pre)

# calculate the week vbi by the weighted sum of hashtag vbis
after_pre_week = precentage_counts_matrix.T.dot(np.array(after_pre_list))
viral_broacast_2 = after_pre_week

# store the derivatives into csv file
hashtag_derivatives_df = pd.DataFrame({"gini": gini_list,
                                      "vbi1": viral_broacast_1,
                                      "vbi2": viral_broacast_2})
hashtag_derivatives_df.to_csv("/data/data_and_derivatives/derivatives/vbi_and_weekeventfulness.csv")
