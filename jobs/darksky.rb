# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require "open-uri"

SCHEDULER.every '1m', :first_in => 0 do |job|
  json = JSON.parse(URI.parse("https://api.forecast.io/forecast/edb8144bb805b9cd323bfe20f1c08e4a/40.024888,-83.001876").read)
#  json = JSON.parse(URI.parse("https://api.forecast.io/forecast/edb8144bb805b9cd323bfe20f1c08e4a/38.2581,-93.9814").read)

  upcoming = []

  json['minutely']['data'].length.times do |i|
    upcoming << ({ x: i+1, y: json['minutely']['data'][i]['precipIntensity'] })
  end

  send_event('darksky', { points: upcoming, minutely_summary: json['minutely']['summary'], hourly_summary: json['hourly']['summary'] })
end
