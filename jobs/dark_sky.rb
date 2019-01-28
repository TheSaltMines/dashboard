require 'net/https'
require 'json'

# Forecast API Key from https://developer.forecast.io
forecast_api_key = ENV["DARKSKY_API_KEY"] || "THE_API_KEY"

# Latitude, Longitude for location
forecast_location = "40.024888,-83.001876"

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
forecast_units = "si"


SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.darksky.net", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location}?units=#{forecast_units}"))
  forecast = JSON.parse(response.body)
  forecast_current_temp = forecast["currently"]["temperature"].round
  forecast_current_icon = forecast["currently"]["icon"]
  forecast_current_desc = forecast["currently"]["summary"]

  if forecast["minutely"]
    upcoming = forecast['minutely']['data'].each_with_index.map { |d, i| { x: i, y: d['precipIntensity'] } }

    send_event('dark_sky', {
                 points: upcoming,
                 minutely_summary: forecast['minutely']['summary'],
                 hourly_summary: forecast['hourly']['summary']})

    send_event('forecast', {
                 current_temp: "#{forecast["currently"]["temperature"].round}&deg;",
                 current_icon: "#{forecast["currently"]["icon"]}",
                 current_desc: "#{forecast["currently"]["summary"]}",
                 next_icon: "#{forecast["minutely"]["summary"]}",
                 next_desc: "#{forecast["minutely"]["icon"]}",
                 later_icon: "#{forecast["hourly"]["icon"]}",
                 later_desc: "#{forecast["hourly"]["summary"]}"})
  end
end
