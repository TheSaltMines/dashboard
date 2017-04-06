# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'rexml/document'
SCHEDULER.every '5s', :first_in => 0 do |job|
  http = Net::HTTP.new('ws.audioscrobbler.com')
  response = http.request(Net::HTTP::Get.new("/2.0/?method=user.getrecenttracks&user=thesaltmines&api_key=845d3d4cdeae6e94f8f989e92f1756d0&limit=5&extended=1"))
  doc = REXML::Document.new(response.body)

  tracks = []
  doc.elements.each('lfm/recenttracks/track') { |element|
    track = element.elements["name"].text
    artist = element.elements["artist/name"].text
    cover = element.elements["image[@size='large']"].text ||
            element.elements["artist/image[@size='large']"].text

    tracks.push({ cover: cover, track: track, artist: artist })
  }

  # Sometimes the now playing track is repeated
  np, *upcoming = tracks.uniq.take(4)

  send_event('radio', { npcover: np[:cover], nptrack: np[:track], npartist: np[:artist], upcoming: upcoming})
end
