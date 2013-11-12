require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
Twitter.configure do |config|
  config.consumer_key = 'eWBpw4omptJd8ClCdKqQ'
  config.consumer_secret = 'lYXrxXEqylIAK1oihHNoPcDC7XfW1b2I0hVJ1PA'
  config.oauth_token = '818615719-LbKZueyjpg4Sb40V8ds36x13HaWmRnaeqPMmyR06'
  config.oauth_token_secret = 'JDX4PybWXfMfYNHZ30Q04b0xZRDa5pRGMZaM8KyXoybgT'
end

search_term = URI::encode('@TheSaltMines')

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = Twitter.search("#{search_term}").results

    if tweets
      tweets.map! do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end
      send_event('twitter_mentions', comments: tweets)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end