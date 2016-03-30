Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/visualization-graph-info.handlebars'

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
    # Update template & render if we have node info
    if @node
      # Compile the template using Handlebars
      @template = HandlebarsTemplate {name: @node.name, description: @node.description}
      #console.log 'template', @template
      @$el.find('.panel-body').html @template, @
    return this

module.exports = VisualizationGraphInfo