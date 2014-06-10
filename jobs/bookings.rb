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
  
  upcoming = Hash.new({ value: 0 })   
  i = 0
  events.each do |event|  

    dtstart     = reDTSTART.match event
    dtend       = reDTEND.match event
    summary     = reSUMMARY.match event
    description = reDESCRIPTION.match event
    
    if dtstart 

    
      dtstart = DateTime.parse(dtstart[1])# - (5.0/24.0) # Subtract 5 hours for timezone
      dtend   = DateTime.parse(dtend[1])# - (5.0/24.0) # Subtract 5 hours for timezone

      
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
               
        
        upcoming[i] = { summary: summary, startdate: { hour: dtstart.hour%12, minute: "%02d"%dtstart.min, ampm: (dtstart.hour>12?'pm':'am'), year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { hour: dtend.hour%12, minute: "%02d"%dtend.min, ampm: (dtend.hour>12?'pm':'am'), year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
        i+=1
      end
    else
      dtstart = reDTSTART_allday.match event
      dtend   = reDTEND_allday.match event   
      
      if dtstart       
      
        dtstart = Date.parse(dtstart[1])
        dtend   = Date.parse(dtend[1])
        
        if dtstart > DateTime.now 
          if summary  
            summary = summary[1]
          else
            summary = 'no details'
          end
          
          upcoming[i] = { summary: description, startdate: { year: dtstart.year, month: Date::MONTHNAMES[dtstart.month], day: dtstart.day, dayofweek: Date::DAYNAMES[dtstart.cwday] }, enddate: { year: dtend.year, month: Date::MONTHNAMES[dtend.month], day: dtend.day, dayofweek: Date::DAYNAMES[dtend.cwday] } }
          i+=1
        
        end
      end              
    end
  end

  send_event('events', { upcoming: upcoming.values[0..3] })
end