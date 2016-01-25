class VisualizationGraphNavigation extends Backbone.View

  el: '.visualization-graph-menu-navigation'

  initialize: ->
    @render()

  render: -> 
    @$el.find('.zoomin').click ->
      $(this).trigger 'blur'
      Backbone.trigger 'visualization.navigation.zoomin'
    @$el.find('.zoomout').click ->
      $(this).trigger 'blur'
      Backbone.trigger 'visualization.navigation.zoomout'
    @$el.find('.fullscreen').click ->
      $(this).trigger 'blur'
      Backbone.trigger 'visualization.navigation.fullscreen'
    return this

module.exports = VisualizationGraphNavigation