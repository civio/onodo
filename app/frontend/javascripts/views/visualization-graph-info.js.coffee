Handlebars = require 'handlebars'

class VisualizationGraphInfo extends Backbone.View

  el: '.visualization-graph-info'

  show: (node) ->
    @node = node
    @$el.addClass('active')
    @$el.find('.panel-heading > a.btn').attr('href','/nodes/'+node.id+'/edit/')
    @render()

  hide: ->
    @$el.removeClass('active')

  initialize: ->
    @$el.find('.close').click (e) ->
      e.preventDefault()
      Backbone.trigger 'visualization.node.hideInfo'
    @render()

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