class VisualizationLegend extends Backbone.View

  el: '.visualization-graph-legend'

  parameters: null

  setup: ( _parameters ) ->
    @parameters = _parameters

  render: ( scale_size, scale_color ) ->

    if !@parameters.showLegend or ((!scale_color or scale_color.domain().length <= 1 ) and (!scale_size or scale_size.domain()[0] == scale_size.domain()[1]))
      @$el.hide()
      return

    # Check if both size & color use same column in order to paint together !!!

    @$el.show()

    # listen to click on collapse btn
    @$el.find('.panel-heading, .panel-body .visualization-graph-legend-collapse-btn').click @onCollapseBtnClick

    # Setup size legend
    if scale_size and scale_size.domain()[0] != scale_size.domain()[1]

      # add class size to element
      @$el.addClass 'size'

      # create legend size group
      legend_size = @$el.find('.visualization-graph-legend-size').show()

      # add legend size title
      legend_size.find('.visualization-graph-legend-title').html( @parameters.nodesSizeColumn.replace('_',' ').trim().capitalize() )

      sm_size = scale_size.domain()[0]
      lg_size = scale_size.domain()[1]
      md_size = sm_size + ((lg_size - sm_size)*0.5)
      
      legend_size.find('.visualization-graph-legend-lg .visualization-graph-legend-size-amount').html( @formatNumber(lg_size) )
      legend_size.find('.visualization-graph-legend-md .visualization-graph-legend-size-amount').html( @formatNumber(md_size) )
      legend_size.find('.visualization-graph-legend-sm .visualization-graph-legend-size-amount').html( @formatNumber(sm_size) )
    else
      @$el.find('.visualization-graph-legend-size').hide()

    # Setup color legend
    if ( @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative' ) and scale_color.domain().length > 1

      # add class color to element
      @$el.addClass 'color'

      # Avoid quantitative scales with same values
      if scale_color.domain().length == 2 and scale_color.domain()[0] == scale_color.domain()[1]
        @$el.find('.visualization-graph-legend-color').hide()
        return

      # Create legend color group
      legend_color = @$el.find('.visualization-graph-legend-color').show()
      legend_color.addClass @parameters.nodesColor
      legend_color.find('ul li').remove()

      # Add legend color title
      legend_color.find('.visualization-graph-legend-title').html( @parameters.nodesColorColumn.replace('_',' ').trim().capitalize() )

      items = scale_color.domain()

      # Insert values inside domain for quantitative scales
      if @parameters.nodesColor == 'quantitative'
        items = items.sort (a, b) -> return a - b 
        steps = (items[0] - items[1]) / 5
        min = items.pop()
        items.push @formatNumber(items[0]-steps)
        items.push @formatNumber(items[1]-steps)
        items.push @formatNumber(items[2]-steps)
        items.push @formatNumber(items[3]-steps)
        items.push min

      # loop through all colors
      items.forEach (item, i) =>
        if item != null and item != ''
          # create legend item
          legend_item = $('<li></li>')
          # add circle & amount to legend item 
          legend_item_color = $('<span class="visualization-graph-legend-square"></span>')
          legend_item_color.css('background-color': scale_color(item) )
          legend_item.append legend_item_color
          # skip first item label if scale is quantitative
          if i > 0 || @parameters.nodesColor == 'qualitative'
            legend_item.append item
          legend_color.find('ul').append legend_item
    else
      @$el.find('.visualization-graph-legend-color').hide()


  onCollapseBtnClick: (e) =>
    @$el.toggleClass 'collapsed'


  formatNumber: (number) ->
    number = parseFloat(number)
    return if number%1 != 0 and number < 2 then number.toFixed(1) else number|0

  String.prototype.capitalize = () ->
    return this.charAt(0).toUpperCase() + this.slice(1)

module.exports = VisualizationLegend