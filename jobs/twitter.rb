require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'eWBpw4omptJd8ClCdKqQ'
  config.consumer_secret = 'lYXrxXEqylIAK1oihHNoPcDC7XfW1b2I0hVJ1PA'
  config.access_token = '818615719-LbKZueyjpg4Sb40V8ds36x13HaWmRnaeqPMmyR06'
  config.access_token_secret = 'JDX4PybWXfMfYNHZ30Q04b0xZRDa5pRGMZaM8KyXoybgT'
end

SCHEDULER.every '10m', :first_in => 0 do |job|
  begin
    tweets = client.search(URI::encode('@TheSaltMines'))

    if tweets.count > 0
      tweets_hash = tweets.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https.to_s.sub('normal','bigger') }
      end
      send_event('twitter_mentions', comments: tweets_hash)
    end
  rescue Twitter::Error
    puts "\e[33mFor the twitter widget to work, you need to put in your twitter API keys in the jobs/twitter.rb file.\e[0m"
  end
end