# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'date'

SCHEDULER.every '1m', :first_in => 0 do |job|
  cal_file=(Net::HTTP.get 'saltmines.us', '/eo-events')
  events = cal_file.split('BEGIN:')
  
  reDTSTART = /DTSTART:(\d\d\d\d\d\d\d\dT\d\d\d\d\d\dZ)/
  reDTEND   = /DTEND:(\d\d\d\d\d\d\d\dT\d\d\d\d\d\dZ)/
  reSUMMARY = /SUMMARY:\s*(.*)\s*DESCRIPTION/
  
  upcoming = Hash.new({ value: 0 })   
  i = 0
  events.each do |event|  

    dtstart = reDTSTART.match event
    dtend   = reDTEND.match event
    summary = reSUMMARY.match event
    
    if dtstart 
      dtstart = DateTime.parse(dtstart[1]) - (5.0/24.0) # Subtract 5 hours for timezone
      dtend   = DateTime.parse(dtend[1]) - (5.0/24.0) # Subtract 5 hours for timezone
      
      if dtstart > DateTime.now 
            
        if summary  
          summary = summary[1]
        else
          summary = 'no details'
        end
        
        upcoming[i] = { summary: summary, startdate: { hour: dtstart.hour%12, minute: "%02d"%dtstart.min, ampm: (dtstart.hour%12>12?'pm':'am'), year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { hour: dtend.hour%12, minute: "%02d"%dtend.min, ampm: (dtend.hour%12>12?'pm':'am'), year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
        i+=1
      end
    end
  end

  send_event('events', { upcoming: upcoming.values[0..5] })
end