# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'json'
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('radio.saltmines.us')
  response = http.request(Net::HTTP::Get.new("/controller.php?r=getQueue"))
  json = JSON.parse(response.body)
  npcover = json['queue'][0]['bigIcon']
  nptitle = json['queue'][0]['name']
  npartist = json['queue'][0]['artist']  

  send_event('radio', { npcover: npcover, nptitle: nptitle, npartist: npartist})
end