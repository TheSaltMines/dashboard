# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'json'

SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('saltmines.us')
  response = http.request(Net::HTTP::Get.new("/gyrocount.php"))
  json = JSON.parse(response.body)
  theCount = json['count']

  send_event('gyro', { current: theCount })
end