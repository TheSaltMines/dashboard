# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'date'

SCHEDULER.every '1m', :first_in => 0 do |job|
  cal_file=(Net::HTTP.get 'booking.saltmines.us', '/info/webcal/258B66.ics')
  events = cal_file.split('BEGIN:')
  
  reDTSTART = /DTSTART;TZID=[^:]+:(\d\d\d\d\d\d\d\dT\d\d\d\d\d\d)/
  reDTEND   = /DTEND;TZID=[^:]+:(\d\d\d\d\d\d\d\dT\d\d\d\d\d\d)/
  reDTSTART_allday = /DTSTART;VALUE=DATE:(\d\d\d\d\d\d\d\d)/
  reDTEND_allday   = /DTEND;VALUE=DATE:(\d\d\d\d\d\d\d\d)/    
  
  reSUMMARY = /SUMMARY:\s*(.*)\s*(DESCRIPTION|ORGANIZER)/
  reDESCRIPTION = /DESCRIPTION:\s*(.*)\s*(CREATED|ORGANIZER)/  
  
  today = Hash.new({ value: 0 })   
  thisweek = Hash.new({ value: 0 })     
  later = Hash.new({ value: 0 })     
  
  i = 0
  max_events = 4
  events.each do |event|  

    dtstart     = reDTSTART.match event
    dtend       = reDTEND.match event
    summary     = reSUMMARY.match event
    description = reDESCRIPTION.match event
    
    if dtstart 

    
      dtstart = DateTime.parse(dtstart[1])
      dtend   = DateTime.parse(dtend[1])

      
      if dtstart > DateTime.now 
            
        if summary  
          summary = summary[1].strip
        else
          summary = 'no details'
        end
        
        if description  
          description = description[1].strip
        else
          description = summary
        end
        
        summary = "#{description} (#{summary})"
        time = Time.new()
        today_start = Time.new(time.year, time.month, time.day)
        today_end = today_start + 86399
        thisweek_end = today_start + 604799
        
        if (today_start..today_end).cover?(dtstart.to_time()) && (i<max_events)
              today[today.length] = { summary: summary, startdate: { hour: dtstart.hour%12, minute: "%02d"%dtstart.min, ampm: (dtstart.hour>12?'pm':'am'), year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { hour: dtend.hour%12, minute: "%02d"%dtend.min, ampm: (dtend.hour>12?'pm':'am'), year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
              
        elsif (today_start..thisweek_end).cover?(dtstart.to_time()) && (i<max_events)
              thisweek[thisweek.length] = { summary: summary, startdate: { hour: dtstart.hour%12, minute: "%02d"%dtstart.min, ampm: (dtstart.hour>12?'pm':'am'), year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { hour: dtend.hour%12, minute: "%02d"%dtend.min, ampm: (dtend.hour>12?'pm':'am'), year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
          
        elsif (i<max_events)
              later[later.length] = { summary: summary, startdate: { hour: dtstart.hour%12, minute: "%02d"%dtstart.min, ampm: (dtstart.hour>12?'pm':'am'), year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { hour: dtend.hour%12, minute: "%02d"%dtend.min, ampm: (dtend.hour>12?'pm':'am'), year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
        end
        
        
        i+=1
      end
    end
  end
  


  send_event('events', { today: today.values[0..3], thisweek: thisweek.values[0..3], later: later.values[0..3] })
end