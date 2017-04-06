# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'rexml/document'
SCHEDULER.every '5s', :first_in => 0 do |job|
  http = Net::HTTP.new('ws.audioscrobbler.com')
  response = http.request(Net::HTTP::Get.new("/2.0/?method=user.getrecenttracks&user=thesaltmines&api_key=845d3d4cdeae6e94f8f989e92f1756d0&limit=5&extended=1"))
  doc = REXML::Document.new(response.body)

  tracks = Array.new
  doc.elements.each('lfm/recenttracks/track') { |element|
    track = element.elements["name"].text
    artist = element.elements["artist/name"].text

    cover = element.elements["image[@size='large']"].text
    if cover.nil?
      cover = element.elements["artist/image[@size='large']"].text
    end

    tracks.push({ cover: cover, track: track, artist: artist })
  }

  np, upcoming = tracks[0], tracks[1..-1]

  # Sometimes the now playing track is repeated
  if np == upcoming[0]
    upcoming = upcoming[1..-1]
  else
    upcoming = upcoming[0..-2]
  end

  send_event('radio', { npcover: np[:cover], nptrack: np[:track], npartist: np[:artist], upcoming: upcoming})
end
