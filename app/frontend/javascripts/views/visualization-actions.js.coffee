class VisualizationActions extends Backbone.View

  el: '.visualization-graph-menu-actions'
  share_panel: null
  
  initialize: ->
    @share_panel = $('#visualization-share')
    @render()

  render: -> 
     # Setup Share Panel Show/Hide
    @$el.find('.btn-share').click      @onPanelShareShow
    @share_panel.find('.close').click  @onPanelShareHide
    return this

  # Panel Share Events
  onPanelShareShow: =>
    @share_panel.addClass 'active'

  onPanelShareHide: =>
    @share_panel.removeClass 'active'

module.exports = VisualizationActions