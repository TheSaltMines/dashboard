class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    m_names = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
    d_names = new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");

    h = today.getHours()
    m = today.getMonth();
    d = today.getDay();
    if (h>=12)
      AorP="PM";
    else
      AorP="AM";

    if (h>=13)
      h-=12;
    if (h==0)
      h=12;

    m = today.getMinutes()
    m = @formatTime(m)
    @set('time', h + ":" + m + " " + AorP)
    @set('date', d_names[today.getDay()]+", "+m_names[today.getMonth()]+" "+today.getDate())

  formatTime: (i) ->
    if i < 10 then "0" + i else i
