# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'json'
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('saltmines.us')
  response = http.request(Net::HTTP::Get.new("/script/buzzbot-read-v2.php"))
  json = JSON.parse(response.body)
  
  today     = Hash.new({ value: 0 }) 
  thisweek  = Hash.new({ value: 0 })   
  earlier   = Hash.new({ value: 0 }) 
    
  json['today'].length.times do |i|
    if i>=0 && i<6  && json['today'][i]['topic'].to_s.length>0
      today[i-1] = { topic: json['today'][i]['topic'], author: json['today'][i]['author'], contributors: json['today'][i]['contributors'], posts: json['today'][i]['posts'], latest: json['today'][i]['latest'] }
    end
  end
  
  json['thisweek'].length.times do |i|
    if i>=0 && i<6  && json['thisweek'][i]['topic'].to_s.length>0
      thisweek[i-1] = { topic: json['thisweek'][i]['topic'], author: json['thisweek'][i]['author'], contributors: json['thisweek'][i]['contributors'], posts: json['thisweek'][i]['posts'], latest: json['thisweek'][i]['latest'] }
    end
  end  

  json['earlier'].length.times do |i|
    if i>=0 && i<6  && json['earlier'][i]['topic'].to_s.length>0
      earlier[i-1] = { topic: json['earlier'][i]['topic'], author: json['earlier'][i]['author'], contributors: json['earlier'][i]['contributors'], posts: json['earlier'][i]['posts'], latest: json['earlier'][i]['latest'] }
    end
  end  

  send_event('groupbuzz', { today: today.values, thisweek: thisweek.values, earlier: earlier.values })
end