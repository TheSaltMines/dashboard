require 'net/http'
require 'json'
require 'date'

module XKCD
  extend self

  XKCD_URI = 'https://xkcd.com'
  DATE_FORMAT_STR = '%B %-d, %Y'

  def fetch(id = nil)
    uri = URI.join(XKCD_URI, id.to_s + '/', 'info.0.json')
    response = Net::HTTP.get(uri)
    JSON.parse(response).tap do |xkcd|
      xkcd_date = Date.new(xkcd['year'].to_i, xkcd['month'].to_i, xkcd['day'].to_i)
      xkcd['datestr'] = xkcd_date.strftime(DATE_FORMAT_STR)
    end
  end

  def current
    # With no id, gets current
    fetch
  end

  def random
    curr_id = fetch_by_id_or_current['num']
    random_id = 404
    random_id = rand(1..curr_id) while random_id == 404
    fetch_by_id_or_current(random_id)
  end
end

SCHEDULER.every '1d', :first_in => 0 do |job|
  send_event('daily_xkcd', XKCD.current)
end
