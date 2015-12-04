class VisualizationGraphNavigation extends Backbone.View

  el: '.visualization-graph-menu-navigation'

  initialize: ->
    @render()

  render: -> 
    @$el.find('.zoomin').click ->
      Backbone.trigger 'visualization.navigation.zoomin'
    @$el.find('.zoomout').click ->
      Backbone.trigger 'visualization.navigation.zoomout'
    @$el.find('.fullscreen').click ->
      Backbone.trigger 'visualization.navigation.fullscreen'
    return this

module.exports = VisualizationGraphNavigation