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
      
      # create legend size group
      legend_size = @$el.find('.visualization-graph-legend-size').show()

      # add legend size title
      legend_size.find('.visualization-graph-legend-title').html( @parameters.nodesSizeColumn.replace('_',' ').trim().capitalize() )

      sm_size = scale_size.domain()[0]
      lg_size = scale_size.domain()[1]
      md_size = sm_size + ((lg_size - sm_size)*0.5)
      
      legend_size.find('.visualization-graph-legend-lg .visualization-graph-legend-size-amount').html( if lg_size%1 != 0 then lg_size.toFixed(1) else lg_size )
      legend_size.find('.visualization-graph-legend-md .visualization-graph-legend-size-amount').html( if md_size%1 != 0 then md_size.toFixed(1) else md_size )
      legend_size.find('.visualization-graph-legend-sm .visualization-graph-legend-size-amount').html( if sm_size%1 != 0 then sm_size.toFixed(1) else sm_size )
    else
      @$el.find('.visualization-graph-legend-size').hide()

    # Setup color legend
    if ( @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative' ) and scale_color.domain().length > 1
    
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