Node                  = require './../models/node.js'
Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/visualization-graph-info.handlebars'

class VisualizationGraphInfo extends Backbone.View

  el: '.visualization-graph-info'

  show: (node) ->
    # We receive node as an object, so we need to convert into Node model
    @node = new Node(node)
    @$el.addClass('active')
    @$el.find('.panel-heading > a.btn').attr('href','/nodes/'+node.id+'/edit/')
    @render()

  hide: ->
    @$el.removeClass('active')

  isVisible: ->
    return @$el.hasClass('active')

  initialize: ->
    @$el.find('.close').click (e) ->
      e.preventDefault()
      Backbone.trigger 'visualization.node.hideInfo'
    @render()

  render: ->
    # Update template & render if we have node info
    if @node
      # Compile the template using Handlebars
      @template = HandlebarsTemplate {
        name: @node.get('name')
        description: @node.get('description')
        image: if @node.get('image') then @node.get('image').huge.url else null
      }
      #console.log 'template', @template
      @$el.find('.panel-body').html @template, @
    return this

module.exports = VisualizationGraphInfo