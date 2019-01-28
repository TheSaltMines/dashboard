require 'net/http'
require 'json'
require 'date'

XKCD_URI = 'http://xkcd.com'
DATE_FORMAT_STR = '%B %-d, %Y'

$displayed_xkcd = nil
$prev_displayed_xkcd = nil

# Get's the nth xkcd entry, unless
# nil is passed, in which case current
def get_nth_xkcd(n)
  uri = URI.join(XKCD_URI, n.to_s + '/', 'info.0.json')
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

# Get's the current, featured xkcd entry
def get_current_xkcd
  get_nth_xkcd(nil)
end

# Get's a random xkcd
def get_random_xkcd
  curr_id = get_current_xkcd['num']
  random_id = nil

  # 404 is reserved for Not found
  while true do
    random_id = rand(curr_id)
    break if random_id != 404
  end
  get_nth_xkcd(random_id)
end

# Check if provided xkcd was published yesterday
def published_yesterday_and_unseen(xkcd_date)
  xkcd_date == Date.today.prev_day and ($prev_displayed_xkcd.nil? or not $prev_displayed_xkcd['num'] == xkcd['num'])
end

# Basic logic:
#  - if an xkcd was published today, display it.
#  - if an xkcd was published yesterday, and we didn't
#    show it yesterday, display it.
#  - otherwise, display a random xkcd.
SCHEDULER.every '1d', :first_in => 0 do |job|
  $prev_displayed_xkcd = $displayed_xkcd

  xkcd = get_current_xkcd
  xkcd_date = Date.new(
    xkcd['year'].to_i,
    xkcd['month'].to_i,
    xkcd['day'].to_i
  )
  if xkcd_date == Date.today or published_yesterday_and_unseen(xkcd_date)
    $displayed_xkcd = xkcd
  else
    $displayed_xkcd = get_random_xkcd
    xkcd_date = Date.new(
      $displayed_xkcd['year'].to_i,
      $displayed_xkcd['month'].to_i,
      $displayed_xkcd['day'].to_i
    )
  end
  $displayed_xkcd['datestr'] = xkcd_date.strftime(DATE_FORMAT_STR)
  send_event('xkcd-of-the-day', $displayed_xkcd)
end
