import pandas as pd
from os import listdir
from os.path import isfile, join
from datetime import datetime
import numpy as np

from nltk.tokenize import TweetTokenizer
tweet_tokenizer = TweetTokenizer()
from nltk.corpus import stopwords 
english_stopwords = stopwords.words("english")
english_stopwords = english_stopwords + ['RT']
import string
import re
from nltk.stem.porter import *
stemmer = PorterStemmer()

from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import pairwise_distances, cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.feature_extraction.text import CountVectorizer

tfidfVectorizer = TfidfVectorizer()
countVectorizer = CountVectorizer()
from collections import OrderedDict
import scipy

# defining the tokenizer
def my_tokenizer(tweet):
    # tokenize into list
    sentence = tweet_tokenizer.tokenize(tweet)
    # filter out stopwords
    filtered_sentence = [w for w in sentence if not w in english_stopwords and not
                         re.match('[^A-Za-z0-9]+', w) and not 'https://' in w]
    # stemmer
    filtered_sentence = [stemmer.stem(word) for word in filtered_sentence]
    # join into a sentence for tfidf transformation later
    filtered_sentence = ' '.join(filtered_sentence)
    return filtered_sentence

# for botometer threstholds equals to 0.5-1
for i in range(5,11):
    filename = "/data/data_and_derivatives/user_tweets_df_boto_{}.csv".format(i)
    print(filename)
    outputfile = "/data/data_and_derivatives/snetworks_boto{}/".format(i)
    print(outputfile)
    
    # reads the tweets dataframe
    tweets_df = pd.read_csv(filename)
    tweets_df.created_at = pd.to_datetime(tweets_df.created_at) 
    
    # aggregate the tweets dataframe by weeks
    tweets_df_group_by = tweets_df.groupby(['author_id', pd.Grouper(key='created_at', freq='W-MON')])['text'].apply(', '.join).reset_index()
    # remove the last week of 2020 which has only three days in it
    tweets_df_group_by = tweets_df_group_by[tweets_df_group_by.created_at != pd.Timestamp('2021-01-04 00:00:00+0000', tz='UTC')]

    # this dataframe counts how many weeks each user posted a tweets
    # a user that meets our inclusion critira will have exactly 52 weeks
    week_count_df = tweets_df_group_by.groupby('author_id').count().reset_index()
    # select users that has tweets in each week of the 52 weeks
    users = list(week_count_df.author_id[week_count_df.created_at == 52])
    # sort dataframe
    tweets_df_group_by = tweets_df_group_by[tweets_df_group_by.author_id.isin(users)].sort_values(['author_id', 'created_at']).reset_index()
    # obtain list of users
    users = list(tweets_df_group_by.author_id.drop_duplicates())
    print(len(users))

    # apply tokenizer
    tweets_df_group_by['tokenized_text'] = tweets_df_group_by.apply(lambda row: my_tokenizer(row['text']), axis=1)
    tweets_df_group_by = tweets_df_group_by.sort_values(by=['created_at', 'author_id'])
    # apply tfidf matrix converter
    tfidf_matrix = tfidfVectorizer.fit_transform(tweets_df_group_by.tokenized_text)
    # apply PSA to reduce dimensionality to 100
    tsvd_100 = TruncatedSVD(n_components=100)
    tf_itf_tsvd_100 = tsvd_100.fit(tfidf_matrix).transform(tfidf_matrix)
    tf_itf_tsvd_100_df = np.DataFrame(tf_itf_tsvd_100)
    tf_itf_tsvd_100_df.to_csv("/data/data_and_derivatives/tweets_embeddings_boto{}.csv".format(i))




    
