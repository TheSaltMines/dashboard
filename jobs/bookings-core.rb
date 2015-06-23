require 'icalendar'

class Bookings

  def initialize(params)
    @params = params
  end

  def run
    SCHEDULER.every '1m', :first_in => 0 do |job|
      cal_file=(Net::HTTP.get 'booking.saltmines.us', @params[:ical_path])
      calendar = Icalendar.parse(cal_file).first
      events = filter_upcoming(calendar.events).map { |e| event_to_hash(e) }
      send_event(@params[:data_id], { events: events.take(5) })
    end
  end

  private
  
    def event_to_hash(event)
      {
        summary: summary(event),
        date: format_date(event.dtstart),
        starttime: format_time(event.dtstart),
        endtime: format_time(event.dtend)
      }
    end

    def format_date(date)
      if date.to_date == Date.today
        'Today'
      else
        date.strftime('%A, %b %-d')   # Tuesday, Jun 23
      end
    end
  
    def format_time(time)
      if time.min == 0
        time.strftime('%-l%P')        # 3pm
      else
        time.strftime('%-l:%M%P')     # 3:15pm
      end
    end
  
    def filter_upcoming(all_events)
      all_events.select { |e| e.dtend > DateTime.now }
    end

    # event.summary is the creator's name
    # event.description is the description that they entered.
    def summary(event)
      if is_valid_description?(event.description) && event.summary
        "#{event.summary} - #{event.description}"
      elsif is_valid_description?(event.description)
        event.description
      elsif event.summary
        event.summary
      else
        "no details"
      end
    end

    # If no description was entered, SuperSAAS sets the description to the event's URL.
    # We want to ignore those descriptions.
    def is_valid_description?(description)
      description && !description.include?('http://')
    end
end
