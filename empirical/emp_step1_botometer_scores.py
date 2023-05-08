import numpy as np
import botometer
import pandas as pd
import pickle

# defines the api keys for tweepy and botometer api
access_token_key = 'YOUR ACCESS TOKEN KEY'
access_token_secret = 'YOUR ACCESS TOKEN KEY'
consumer_key = 'YOUR COMSUMER KEY'
consumer_secret = 'YOUR CONSUMER SECRET'
rapidapi_key = "YOUR BOTOMETER RAPIDAPI KEY"

twitter_app_auth = {
    'consumer_key': consumer_key,
    'consumer_secret': consumer_secret,
    'access_token': access_token_key,
    'access_token_secret': access_token_secret,
  }

# define the botometer api
bom = botometer.Botometer(wait_on_ratelimit=True,
                          rapidapi_key=rapidapi_key,
                          **twitter_app_auth)

# load the list of valid users
valid_users=pd.read_csv('valid_users.txt', sep=",", header=None)[0].tolist() 

# Check a sequence of accounts
result_list = []
screen_name_list = []
for screen_name, result in bom.check_accounts_in(valid_users):
    result_list.append(result)
    screen_name_list.append(screen_name)

# make the botometer metrics into a dataframe
boto_dict = {}

# we read the result of the returned botometer scores. 
for i in range(len(botometer_list)):
    try:
        boto_dict[botometer_list[i]['user']['user_data']['id_str']] = botometer_list[i]['cap']['english']
    except:
        pass

# We make the botometer scores into a dataframe
botometer_df = pd.DataFrame.from_dict(boto_dict.items())
botometer_df.columns = ['id', 'botometer']

# Save the botometer scores into a csv file
botometer_df.to_csv("/data/botometer_scores.csv")