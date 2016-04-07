require 'net/http'
require 'xmlsimple'
 
# Get a WOEID (Where On Earth ID)
# for your location from here:
# http://woeid.rosselliot.co.nz/
woe_id = 12776196
 
# Temerature format:
# 'c' for Celcius
# 'f' for Fahrenheit
temperature_format = 'f'
 
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('query.yahooapis.com')
  query = "select item.condition, location from weather.forecast where woeid=#{woe_id}"
  request_path = "/v1/public/yql?u=#{temperature_format}&format=json&q=#{URI.escape(query)}"
  response = http.request(Net::HTTP::Get.new(request_path))
  weather_data = JSON.parse(response.body).deep_symbolize_keys
  conditions = weather_data[:query][:results][:channel][:item][:condition]
  location = weather_data[:query][:results][:channel][:location]
  send_event('weather', {
    temp: "#{conditions[:temp]}&deg;#{temperature_format.upcase}",
    condition: conditions[:text],
    title: "#{location[:city]}",
    climacon: climacon_class(conditions[:code])
  })
end


def climacon_class(weather_code)
  case weather_code.to_i
  when 0 
    'tornado'
  when 1 
    'tornado'
  when 2 
    'tornado'
  when 3 
    'lightning'
  when 4 
    'lightning'
  when 5 
    'snow'
  when 6 
    'sleet'
  when 7 
    'snow'
  when 8 
    'drizzle'
  when 9 
    'drizzle'
  when 10 
    'sleet'
  when 11 
    'rain'
  when 12 
    'rain'
  when 13 
    'snow'
  when 14 
    'snow'
  when 15 
    'snow'
  when 16 
    'snow'
  when 17 
    'hail'
  when 18 
    'sleet'
  when 19 
    'haze'
  when 20 
    'fog'
  when 21 
    'haze'
  when 22 
    'haze'
  when 23 
    'wind'
  when 24 
    'wind'
  when 25 
    'thermometer low'
  when 26 
    'cloud'
  when 27 
    'cloud moon'
  when 28 
    'cloud sun'
  when 29 
    'cloud moon'
  when 30 
    'cloud sun'
  when 31 
    'moon'
  when 32 
    'sun'
  when 33 
    'moon'
  when 34 
    'sun'
  when 35 
    'hail'
  when 36 
    'thermometer full'
  when 37 
    'lightning'
  when 38 
    'lightning'
  when 39 
    'lightning'
  when 40 
    'rain'
  when 41 
    'snow'
  when 42 
    'snow'
  when 43 
    'snow'
  when 44 
    'cloud'
  when 45 
    'lightning'
  when 46 
    'snow'
  when 47 
    'lightning'
  end
end