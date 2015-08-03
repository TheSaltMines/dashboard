SCHEDULER.every '5m', :first_in => 0 do |job|
  json = JSON.parse(URI.parse("https://api.forecast.io/forecast/6e02a9830c5bf17a47488e7718159824/40.024888,-83.001876").read)

  upcoming = json['minutely']['data'].each_with_index.map { |d, i| { x: i, y: d['precipIntensity'] } }

  send_event('dark_sky', {
    points: upcoming,
    minutely_summary: json['minutely']['summary'],
    hourly_summary: json['hourly']['summary']
  })
end
