# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'rexml/document'
SCHEDULER.every '1m', :first_in => 0 do |job|
  http = Net::HTTP.new('radioparadise.com')
  response = http.request(Net::HTTP::Get.new("/xml/now.xml"))
  doc = REXML::Document.new(response.body)

  npcover = ""
  nptitle = ""
  npartist = ""
  doc.elements.each('playlist/song') { |element|
    npcover = element.elements["coverart"].text
    nptitle = element.elements["title"].text
    npartist = element.elements["artist"].text
  }

  send_event('radio', { npcover: npcover, nptitle: nptitle, npartist: npartist})
end