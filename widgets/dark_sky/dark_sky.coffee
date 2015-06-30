class Dashing.DarkSky extends Dashing.Widget

  ready: ->
    # Delay render until next event loop. This allows browser to fully render the dashboard
    # so that we calculate the correct width and height for the graph.
    setTimeout => @_createGraph()

  onData: (data) ->
    if @graph
      @graph.series[0].data = data.points
      @graph.render()

  _createGraph: ->
    @graph = new Rickshaw.Graph(
      element: @node
      width: $(@node).outerWidth()
      height: $(@node).outerHeight()
      renderer: 'area'
      series: [
        {
        color: "#AEE0DD",
        data: [{x:0, y:0}]
        }
      ]
      min: 0
      max: 0.4
    )

    @graph.series[0].data = @get('points') if @get('points')

    x_axis = new Rickshaw.Graph.Axis.X(graph: @graph, tickValues: @_xTicks(), tickFormat: @_formatMinutes )
    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickValues: @_yTicks(), tickFormat: @_formatIntensity)
    @graph.render()

  # Specify x and y axis ticks manually so they don't overflow the widget or overlap each other.
  _yTicks: -> [.05, .2, .35]
  _xTicks: -> [10, 20, 30, 40, 50]

  _formatIntensity: (y) ->
    return "Heavy" if (y >= 0.3)
    return "Moderate" if (y >= 0.1)
    return "Light" if (y >= 0.017)
    return "Sprinkles" if (y >= 0.002)
    return ""
  
  _formatMinutes: (x) ->
    parseInt(x) + ' min'
