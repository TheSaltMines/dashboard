require 'net/http'
require 'xmlsimple'
 
# Get a WOEID (Where On Earth ID)
# for your location from here:
# http://woeid.rosselliot.co.nz/
woe_id = 12776196
 
# Temerature format:
# 'c' for Celcius
# 'f' for Fahrenheit
format = 'f'
 
SCHEDULER.every '1s', :first_in => 0 do |job|
  http = Net::HTTP.new('weather.yahooapis.com')
  response = http.request(Net::HTTP::Get.new("/forecastrss?w=#{woe_id}&u=#{format}"))
  weather_data = XmlSimple.xml_in(response.body, { 'ForceArray' => false })['channel']['item']['condition']
  weather_location = XmlSimple.xml_in(response.body, { 'ForceArray' => false })['channel']['location']
  send_event('weather', { :temp => "#{weather_data['temp']}&deg;#{format.upcase}",
                          :condition => weather_data['text'],
                          :title => "#{weather_location['city']}",
                          :climacon => climacon_class(weather_data['code'])})
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