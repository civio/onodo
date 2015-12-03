Handlebars = require 'handlebars'

class VisualizationGraphInfo extends Backbone.View

  show: (node) ->
    @node = node
    @$el.addClass('active')
    @render()

  hide: ->
    @$el.removeClass('active')

  render: ->
    # Compile the template using Handlebars
    @template = Handlebars.compile $('#visualization-graph-info-template').html()
    # Update template & render if we have node info
    if @node
      result = @template {name: @node.name, description: @node.description}
      console.log 'template', result
      @$el.find('.panel-body').html result, @
    return this

module.exports = VisualizationGraphInfo