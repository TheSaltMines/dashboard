SCHEDULER.every '1m', :first_in => 0 do |job|
  json = JSON.parse(URI.parse("https://api.forecast.io/forecast/edb8144bb805b9cd323bfe20f1c08e4a/40.024888,-83.001876").read)

  upcoming = json['minutely']['data'].each_with_index.map { |d, i| { x: i, y: d['precipIntensity'] } }

  send_event('dark_sky', {
    points: upcoming,
    minutely_summary: json['minutely']['summary'],
    hourly_summary: json['hourly']['summary']
  })
end
