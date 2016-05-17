Node                  = require './../models/node.js'
Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/visualization-graph-info.handlebars'

class VisualizationGraphInfo extends Backbone.View

  el: '.visualization-graph-info'

  show: (node) ->
    # We receive node as an object, so we need to convert into Node model
    @model = new Node(node)
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
    # Update template & render if we have a model
    if @model
      # Compile the template using Handlebars
      template = HandlebarsTemplate {
        name:         @model.get('name')
        description:  @model.get('description')
        image:        if @model.get('image') then @model.get('image').huge.url else null
      }
      @$el.find('.panel-body').html template
    return this

module.exports = VisualizationGraphInfo