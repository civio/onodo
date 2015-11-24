class VisualizationGraphNavigationView extends Backbone.View

  render: -> 
    @$el.find('.zoomin').click ->
      Backbone.trigger 'navigation.zoomin'
    @$el.find('.zoomout').click ->
      Backbone.trigger 'navigation.zoomout'
    @$el.find('.fullscreen').click ->
      Backbone.trigger 'navigation.fullscreen'
    return this

module.exports = VisualizationGraphNavigationView