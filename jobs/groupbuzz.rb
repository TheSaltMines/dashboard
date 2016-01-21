class GroupBuzz

  def run
    SCHEDULER.every '1m', :first_in => 0 do |job|
      http = Net::HTTP.new('saltmines.us')
      response = http.request(Net::HTTP::Get.new("/script/buzzbot-read-v2.php"))
      raw_topics = JSON.parse(response.body)

      topics = filter(raw_topics['today']).map { |p| topic_to_hash(p) }
      topics += filter(raw_topics['thisweek']).map { |p| topic_to_hash(p).merge(thisweek: true) }
      topics += filter(raw_topics['earlier']).map { |p| topic_to_hash(p).merge(earlier: true) }
      
      send_event('groupbuzz', { topics: topics.take(6) })
    end
  end

  private
  
    def filter(topics)
      topics.select { |p| p['topic'].present? }
    end
    
    def topic_to_hash(topic)
      {
        topic: topic['topic'],
        contributors: topic['contributors'],
        posts: topic['posts']
      }
    end
end

GroupBuzz.new.run