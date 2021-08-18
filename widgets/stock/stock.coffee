class Dashing.Stock extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('current'))
      if last != 0
        diff = Math.abs(Math.round((current - last) / last * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      if parseInt(@get('current')) > parseInt(@get('last')) then 'fa fa-arrow-up' else 'fa fa-arrow-down'
      
  ready: ->
    # Margins: zero if not set or the same as the opposite margin
    # (you likely want this to keep the chart centered within the widget)
    left = @get('leftMargin') || 0
    right = @get('rightMargin') || left
    top = @get('topMargin') || 0
    bottom = @get('bottomMargin') || 20

    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1) - left - right
    height = (Dashing.widget_base_dimensions[1] * 0.65 * container.data("sizey")) - 35 - top - bottom

    # Lower the chart's height to make space for moreinfo if not empty
    if !!@get('moreinfo')
      height -= 20

    $holder = $("<div class='canvas-holder'></div>")
    $(@node).find('.more-info').before($holder)
    
    canvas = $(@node).find('.canvas-holder')
    
    canvas.append("<canvas width=\"#{width}\" height=\"#{height}\" class=\"chart-area\"/>")

    @ctx = $(@node).find('.chart-area')[0].getContext('2d')

    @myChart = new Chart(@ctx, {
      type: 'line'
      data: {
        labels: @get('labels')
        datasets: @get('datasets')
      },
      options: $.extend({
        responsive: true,
        maintainAspectRatio: true,
        }, @get('options'))
    });

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
    # Load new values and update chart
    if @myChart
      if data.labels then @myChart.data.labels = data.labels
      if data.datasets then @myChart.data.datasets = data.datasets
      if data.options then $.extend(@myChart.options, data.options)

      @myChart.update()
