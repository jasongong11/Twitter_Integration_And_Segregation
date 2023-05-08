The empirical directory includes files to reproduce the data scrapping, data wrangling and data analysis for the twitter discourse network analysis

# emp_step0_tweet_user_sampler.py
- random sample active twitter users using twitter api streaming
- write the sampled tweets and twitter users into csv files
### dependencies:
- python == v3.7
- tweepy == v4.10.0

# emp_step1_botometer_scores.py
- download the botometer scores and save it into a csv file
### dependencies:
- tweepy == v3.1.0
- botometer == v1.6.1

# emp_step2_user_timeline_download.ipynb
- download the users' tweets timeline and save them into a csv file
### dependencies:
- python == v3.7
- tweepy == v4.10.0

# emp_step3_make_tweets_embeddings.py
- load the concatenated tweets dataframe
- aggregate the tweets data by weeks and by users
- nlp preprocessing - tokenize, stopwords filtering, stemming
- convert documents into tf-idf matrix
- apply PSA to reduce dimensions to 100 dims document embeddings
- store the document embeddings into a csv file
### dependencies:
- python == v3.7
- nltk == v3.6.6
- sklearn == v1.1.1

# emp_step4_make_adjacency_matrics.py
- read the document embeddings into a dataframe
- convert the document embeddings into adjacency matrices by pair-wise cosine similarities
### dependencies:
- python == v3.7
- sklearn == v1.1.1

# emp_step5_network_analysis_parfor.m
- load the adjacency matrices
- apply the global threstholding and backbone extraction
- apply the louvian community detection algorithm
- calculate the modularity (segregation) and network density (integration)
- store the derivatives into mat file
### dependencies:
- BCT (https://sites.google.com/site/bctnet/)

# emp_step6_hashtag_analysis.py
- load the grouped tweets dataframe
- extract hashtags
- count hashtags
- calculate vbi and gini by the top 100 hashtags
### dependencies:
- sklearn == v1.1.1


# emp_step7_data_analysis.R
- load the derivatives
- test the hypothesis H1a/b, H2a/b, and H3

# emp_step9_plotting.R
- load the derivatives
- make the plots
### dependencies:
- ggforestplot v2020-04-08
- ggsci v2.9
- hrbrthemes v0.8.0
- cowplot v1.1.1
- RColorBrewer v1.1-3
- viridis v0.6.2
- ggridges v0.5.3
- ggpubr v0.4.0
- gridExtra v2.3
