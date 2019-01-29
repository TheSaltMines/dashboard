class Dashing.Forecast extends Dashing.Widget
  # Overrides Dashing.Widget method in dashing.coffee
  @accessor 'updatedAtMessage', ->
    if updatedAt = @get('updatedAt')
      formatter = Intl.DateTimeFormat('default', {hour: 'numeric', minute: 'numeric'})
      d = new Date(updatedAt)
      "Updated at #{formatter.format(d).toLowerCase()}"

  constructor: ->
    super
    @forecast_icons = new Skycons({"color": "white"})
    @forecast_icons.play()

  ready: ->
    # This is fired when the widget is done being rendered
    @setIcons()

  onData: (data) ->
    # Handle incoming data
    # We want to make sure the first time they're set is after ready()
    # has been called, or the Skycons code will complain.

    if @forecast_icons.list.length
      @setIcons()

  setIcons: ->
    @setIcon('current_icon')
    @setIcon('next_icon')
    @setIcon('later_icon')

  setIcon: (name) ->
    if skycon = @toSkycon(name)
      @forecast_icons.set(name, skycon)

  toSkycon: (data) ->
    if @get(data)
      Skycons[@get(data).replace(/-/g, "_").toUpperCase()]
