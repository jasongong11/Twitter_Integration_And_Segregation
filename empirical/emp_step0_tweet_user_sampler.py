import tweepy
Bearertoken = "PUT YOUR BEARERTOKEN HERE"
import json
auth = tweepy.OAuth2BearerHandler(Bearertoken)
api = tweepy.API(auth, wait_on_rate_limit=True)
import csv

# create a csv file to store the sampled tweets info and twitter account info
writer = csv.writer(open("twitter_users_sample.csv", "wt"))
writer.writerow(['author_id','created_at','id','geo','text','auhtor_name', 'user_created_at',
                 'author_followers_count','author_following_count','author_tweet_count'])

# create the streamer for twitter user sampling
class IDPrinter(tweepy.StreamingClient):
    def on_data(self, raw_data):
        r = json.loads(raw_data.decode())
        author_id = r["data"]["author_id"]
        created_at = r["data"]["created_at"]
        tweet_id = r["data"]["id"]
        place_id = r["data"]["geo"]["place_id"]
        text = r["data"]["text"]

        for user in r["includes"]["users"]:
            if user["id"] == r["data"]["author_id"]:
                user_created_at = user["created_at"]
                username = user["username"]
                followers_count = user["public_metrics"]["followers_count"]
                following_count = user["public_metrics"]["following_count"]
                tweet_count = user["public_metrics"]["tweet_count"]
        writer.writerow([author_id, created_at, tweet_id, place_id, text, username, user_created_at, followers_count, following_count, tweet_count])

# define a printer which writes the sampled twitter users into file
printer = IDPrinter(Bearertoken, wait_on_rate_limit=True)
# add additional rules to restrict users to be english user and country in US
printer.add_rules(tweepy.StreamRule('lang:en place_country:US'), dry_run=True)

# start sampling
printer.filter(expansions='author_id', tweet_fields=['created_at', 'geo'],
               user_fields=['id', 'username', 'created_at', 'public_metrics'])

