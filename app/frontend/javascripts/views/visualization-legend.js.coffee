class VisualizationLegend extends Backbone.View

  el: '.visualization-graph-legend'

  parameters: null

  setup: ( _parameters ) ->
    @parameters = _parameters

  render: ( scale_size, scale_color ) ->

    if !scale_size and !scale_color
      @$el.hide()
      return

    # Check if both size & color use same column in order to paint together !!!

    @$el.show()

    # Setup size legend
    if scale_size
      console.log 'updateLegend size', scale_size.domain(), scale_size.range()

      # create legend size group
      legend_size = @$el.find('.visualization-graph-legend-size').show()
      legend_size.find('ul li').remove()

      # add legend size title
      legend_size.find('.visualization-graph-legend-title').html( @parameters.nodesSizeColumn.replace('_',' ').trim().capitalize() )

      min_size = scale_size.range()[0]
      max_size = scale_size.range()[1]
      steps = (max_size - min_size)*0.5
      i = max_size
      
      # loop through all sizes
      while i >= min_size
        # create legend item
        legend_item = $('<li></li>')
        # add circle & amount to legend item 
        legend_item_circle = $('<span class="visualization-graph-legend-circle"></span>')
        legend_item_circle.css( {'width': (2*i)+'px', 'height': (2*i)+'px', 'border-radius': i+'px', 'left': (max_size-i)+'px'} )
        legend_item_amount = $('<span class="visualization-graph-legend-size-amount"></span>')
        legend_item_amount.html( scale_size.invert(i).toFixed(1) ).css('line-height', (2*i)+'px')
        legend_item.append( legend_item_circle )
        legend_item.append( legend_item_amount )
        legend_size.find('ul').append( legend_item )
        # update counter
        i -= steps
    else
      @$el.find('.visualization-graph-legend-size').hide()

    # Setup color legend
    if ( @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative' ) and scale_color.domain().length > 1
      
      console.log 'updateLegend color', scale_color.domain(), scale_color.range()

      # create legend color group
      legend_color = @$el.find('.visualization-graph-legend-color').show()
      legend_color.find('ul li').remove()

      # add legend color title
      legend_color.find('.visualization-graph-legend-title').html( @parameters.nodesColorColumn.replace('_',' ').trim().capitalize() )

      items = scale_color.domain()

      # Insert values inside domain for quantitative scales
      if @parameters.nodesColor == 'quantitative'
        items = items.reverse()
        steps = (items[1] - items[0]) / 5
        max = items.pop()
        items.push Math.round(items[0]+steps)
        items.push Math.round(items[1]+steps)
        items.push Math.round(items[2]+steps)
        items.push Math.round(items[3]+steps)
        items.push max

      # loop through all colors
      items.forEach (item, i) =>
        console.log item, i
        # create legend item
        legend_item = $('<li></li>')
        # add circle & amount to legend item 
        legend_item_color = $('<span class="visualization-graph-legend-square"></span>')
        legend_item_color.css('background-color': scale_color(item) )
        legend_item.append( legend_item_color )
        legend_item.append( item )
        legend_color.find('ul').append( legend_item )
    else
      @$el.find('.visualization-graph-legend-color').hide()


  String.prototype.capitalize = () ->
    return this.charAt(0).toUpperCase() + this.slice(1)

module.exports = VisualizationLegend