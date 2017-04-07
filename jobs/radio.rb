# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5s', :first_in => 0 do |job|
  np, *upcoming = LastFM.fetch(4)

  send_event('radio', { npcover: np[:cover], nptrack: np[:track], npartist: np[:artist], upcoming: upcoming})
end
