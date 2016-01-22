require 'twitter'

class TwitterJob

  def run
    SCHEDULER.every '10m', :first_in => 0 do |job|
      begin
        # First try to get mentions for @TheSaltMines
        raw_mentions = twitter_client.search(URI::encode('@TheSaltMines'), lang: 'en')
        tweets = filter(raw_mentions).map { |t| tweet_to_hash(t) }
        if raw_mentions.count < 10
          # Search pulls results from the last 7 days. If there aren't many mentions, then include
          # a random selection of tweets containing "The Salt Mines"
          raw_references = twitter_client.search(URI::encode('The Salt Mines'), lang: 'en')
          tweets += filter(raw_references).map { |t| tweet_to_hash(t) }.shuffle.take(100)
        end
        send_event('twitter_mentions', comments: tweets.shuffle)
      rescue Twitter::Error
        puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
      end
    end
  end

  private

    #### Get your twitter keys & secrets:
    #### https://dev.twitter.com/docs/auth/tokens-devtwittercom
    def twitter_client
      @twitter_client || Twitter::REST::Client.new do |config|
        config.consumer_key = 'eWBpw4omptJd8ClCdKqQ'
        config.consumer_secret = 'lYXrxXEqylIAK1oihHNoPcDC7XfW1b2I0hVJ1PA'
        config.access_token = '818615719-LbKZueyjpg4Sb40V8ds36x13HaWmRnaeqPMmyR06'
        config.access_token_secret = 'JDX4PybWXfMfYNHZ30Q04b0xZRDa5pRGMZaM8KyXoybgT'
      end
    end

    def tweet_to_hash(tweet)
      {
        name: CGI.unescapeHTML(tweet.user.name),
        body: CGI.unescapeHTML(tweet.text),
        avatar: tweet.user.profile_image_url_https.to_s.sub('normal','bigger')
      }
    end

    def filter(all_tweets)
      all_tweets.reject { |t| t.user.name.is_a?(Twitter::NullObject) || t.text.is_a?(Twitter::NullObject) }
    end
end

TwitterJob.new.run



