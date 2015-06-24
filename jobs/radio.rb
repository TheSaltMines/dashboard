# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'rexml/document'
SCHEDULER.every '5s', :first_in => 0 do |job|
  http = Net::HTTP.new('radioparadise.com')
  response = http.request(Net::HTTP::Get.new("/xml/now.xml"))
  doc = REXML::Document.new(response.body)

  npcover = ""
  nptrack = ""
  npartist = ""
  doc.elements.each('playlist/song') { |element|
    npcover = element.elements["coverart"].text
    nptrack = element.elements["title"].text
    npartist = element.elements["artist"].text
  }

  response = http.request(Net::HTTP::Get.new("/xml/now_4.xml"))
  i = 0
  doc = REXML::Document.new(response.body)

  upcoming = Hash.new({ value: 0 })
  ppcover = ""
  pptrack = ""
  ppartist = ""
  doc.elements.each('playlist/song') { |element|
    i = i + 1
    if i > 1
      ppcover = element.elements["coverart"].text
      pptrack = element.elements["title"].text
      ppartist = element.elements["artist"].text
      upcoming[i-1] = { cover: ppcover, track: pptrack, artist: ppartist }
    end
  }

  send_event('radio', { npcover: npcover, nptrack: nptrack, npartist: npartist, upcoming: upcoming.values})
end