require "instagram"

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5m', :first_in => 0 do |job|
  Instagram.configure do |config|
    config.client_id = "c60cd0afca0e45e39d126ce7a4524362"
    config.client_secret = "ef2b2b135bdf417fa75da28462900168"
  end

  # foursquare id 53c558c4498e45b1fb371254
  client = Instagram.client()

  images = Array.new

  tags = client.tag_search('smmemberlunch')
  if tags.length > 0
    images.concat(client.tag_recent_media(tags[0].name))
  end

  tags = client.tag_search('thisissaltmines')
  if tags.length > 0
    images.concat(client.tag_recent_media(tags[0].name))
  end

  images = images.flatten

  send_event('instagramimage', { image: images[rand(images.length)].images.standard_resolution.url })
end
