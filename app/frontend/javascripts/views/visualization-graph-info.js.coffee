#require 'hamlcoffee'
#require '../templates/visualization-graph-info'

#VisualizationGraphInfoTemplate = require './../templates/visualization-graph-info'

class VisualizationGraphInfo extends Backbone.View
 
  #template: VisualizationGraphInfoTemplate

  show: ->
    @$el.addClass('active')

  hide: ->
    @$el.removeClass('active')

  # initialize: ->
  #   @model.on 'change', => @render()
 
  # render: ->
  #   @$el.html @template @

module.exports = VisualizationGraphInfo