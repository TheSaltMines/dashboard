require 'net/http'
require 'uri'
require 'rexml/document'

class LastFM
  ENDPOINT = URI.parse("http://ws.audioscrobbler.com/2.0/")
  USER = "thesaltmines"
  API_KEY = "845d3d4cdeae6e94f8f989e92f1756d0"

  def self.get_xml(params)
    uri = ENDPOINT.dup
    uri.query = URI.encode_www_form(params) if params
    response = Net::HTTP.get(uri)
    REXML::Document.new(response)
  end

  def self.fetch(limit)
    doc = get_xml({"method" => "user.getrecenttracks",
                                     "api_key" => API_KEY,
                                     "user" => USER,
                                     "limit" => limit + 1,
                                     "extended" => "1"})
    tracks = []
    doc.elements.each('lfm/recenttracks/track') { |element|
      track = element.elements["name"].text
      artist = element.elements["artist/name"].text
      cover = element.elements["image[@size='extralarge']"].text
      artist_cover = element.elements["artist/image[@size='extralarge']"].text
      mbid = element.elements["mbid"].text
      tracks.push({ artist_cover: artist_cover, cover: cover, track: track, artist: artist, mbid: mbid })
    }
    # Sometimes the now playing track is repeated
    tracks = tracks.uniq.take(4)

    # Fetch missing album artwork, fall back to artist picture
    tracks.each do |track|
      unless track[:cover]
        doc = get_xml({"method" => "track.getInfo",
                       "api_key" => API_KEY,
                       "mbid" => track[:mbid]})
        if cover_elem = doc.elements["lfm/track/album/image[@size='extralarge']"]
          cover = cover_elem.text
        end
        track[:cover] = cover || track[:artist_cover]
      end
    end

    tracks
  end
end
