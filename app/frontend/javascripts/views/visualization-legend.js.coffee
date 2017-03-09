class VisualizationLegend extends Backbone.View

  el: '.visualization-graph-legend'

  parameters: null

  setup: ( _parameters ) ->
    @parameters = _parameters


  render: ( scale_size, scale_color ) ->

    if !@parameters.showLegend or ((!scale_color or scale_color.domain().length <= 1 ) and (!scale_size or scale_size.domain()[0] == scale_size.domain()[1]))
      @$el.hide()
      return

    @$el.show()

    # listen to click on collapse btn
    @$el.find('.panel-heading, .panel-body .visualization-graph-legend-collapse-btn').click @onCollapseBtnClick

    # get scale color domain filtering empty values
    color_domain = scale_color.domain().filter (d) -> !Number.isNaN(d) and d != null and d != ''

    # if size & color columns are the same we draw both scales together
    if @parameters.nodesSizeColumn == @parameters.nodesColorColumn
      if scale_size and scale_size.domain()[0] != scale_size.domain()[1]
        @setupSizeColorLegend scale_size, scale_color, color_domain
      else
        @$el.find('.visualization-graph-legend-size').hide()
    else
      # Setup size legend
      if scale_size and scale_size.domain()[0] != scale_size.domain()[1]
        @setupSizeLegend scale_size
      else
        @$el.find('.visualization-graph-legend-size').hide()
      # Setup color legend
      if ( @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative' ) and color_domain.length > 1
        @setupColorLegend scale_color, color_domain
      else
        @$el.find('.visualization-graph-legend-color').hide()


  setupSizeLegend: (scale_size) ->
    # add class size & show legend size group
    legend_size = @$el.addClass('size').find('.visualization-graph-legend-size').show()

    # add legend size title
    @setLegendTitle legend_size, @parameters.nodesSizeColumn

    sm_size = scale_size.domain()[0]
    lg_size = scale_size.domain()[1]
    md_size = sm_size + ((lg_size - sm_size)*0.5)
    
    legend_size.find('.visualization-graph-legend-lg .visualization-graph-legend-size-amount').html( @formatNumber(lg_size) )
    legend_size.find('.visualization-graph-legend-md .visualization-graph-legend-size-amount').html( @formatNumber(md_size) )
    legend_size.find('.visualization-graph-legend-sm .visualization-graph-legend-size-amount').html( @formatNumber(sm_size) )


  setupColorLegend: (scale_color, color_domain) ->
    # Avoid quantitative scales with same values
    if color_domain.length == 2 and color_domain[0] == color_domain[1]
      @$el.find('.visualization-graph-legend-color').hide()
      return

    # add class color & show legend color group
    legend_color = @$el.addClass('color').find('.visualization-graph-legend-color').show()
    legend_color.addClass @parameters.nodesColor
    legend_color.find('ul li').remove()

    # Add legend color title
    @setLegendTitle legend_color, @parameters.nodesColorColumn
    
    # Insert values inside domain for quantitative scales
    if @parameters.nodesColor == 'quantitative'
      color_domain = color_domain.sort (a, b) -> return a - b 
      steps = (color_domain[0] - color_domain[1]) / 5
      min = color_domain.pop()
      color_domain.push @formatNumber(color_domain[0]-steps)
      color_domain.push @formatNumber(color_domain[1]-steps)
      color_domain.push @formatNumber(color_domain[2]-steps)
      color_domain.push @formatNumber(color_domain[3]-steps)
      color_domain.push min

    # loop through all colors
    color_domain.forEach (item, i) =>
      # create legend item
      legend_item = $('<li></li>')
      # add circle & amount to legend item 
      legend_item_color = $('<span class="visualization-graph-legend-square"></span>')
      legend_item_color.css( 'background-color': scale_color(item) )
      legend_item.append legend_item_color
      # skip first item label if scale is quantitative
      if i > 0 || @parameters.nodesColor == 'qualitative'
        legend_item.append item
      legend_color.find('ul').append legend_item


  setupSizeColorLegend: (scale_size, scale_color, color_domain) ->
    # add class size & color & show legend size group
    legend_size = @$el.addClass('size color').find('.visualization-graph-legend-size').show()

    # add legend size title
    @setLegendTitle legend_size, @parameters.nodesSizeColumn
    
    sm_size = scale_size.domain()[0]
    lg_size = scale_size.domain()[1]
    md_size = sm_size + ((lg_size - sm_size)*0.5)
    
    legend_size.find('.visualization-graph-legend-lg .visualization-graph-legend-size-amount').html( @formatNumber(lg_size) )
    legend_size.find('.visualization-graph-legend-lg .visualization-graph-legend-circle').css
      'background-color': scale_color(lg_size)
      'border': 'none'
     
    legend_size.find('.visualization-graph-legend-md .visualization-graph-legend-size-amount').html( @formatNumber(md_size) )
    legend_size.find('.visualization-graph-legend-md .visualization-graph-legend-circle').css
      'background-color': scale_color(md_size)
      'border': 'none'
      
    legend_size.find('.visualization-graph-legend-sm .visualization-graph-legend-size-amount').html( @formatNumber(sm_size) )
    legend_size.find('.visualization-graph-legend-sm .visualization-graph-legend-circle').css
      'background-color': scale_color(sm_size)
      'border': 'none'


  onCollapseBtnClick: (e) =>
    @$el.toggleClass 'collapsed'


  setLegendTitle: (el, name) ->
    el.find('.visualization-graph-legend-title').html name.replace('_',' ').trim().capitalize()

  formatNumber: (number) ->
    number = parseFloat(number)
    return if number%1 != 0 and number < 2 then number.toFixed(1) else number|0

  String.prototype.capitalize = () ->
    return this.charAt(0).toUpperCase() + this.slice(1)

module.exports = VisualizationLegend