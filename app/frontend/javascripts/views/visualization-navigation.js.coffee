class VisualizationNavigation extends Backbone.View

  el: '.visualization-graph-menu-navigation'

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
    # show configuration menu
    @$el.addClass 'visible'
    return this

module.exports = VisualizationNavigation