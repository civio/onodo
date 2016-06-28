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
    # Setup Search Input Focus Events
    @$el.find('.search-input input').focusin  @onSearchNodeFocus
    @$el.find('.search-input input').focusout @onSearchNodeUnfocus
    return this

  # Panel Share Events
  onPanelShareShow: =>
    @share_panel.addClass 'active'

  onPanelShareHide: =>
    @share_panel.removeClass 'active'

  # Search Node Events
  onSearchNodeFocus: =>
    @$el.find('.search-input').addClass 'focus'

  onSearchNodeUnfocus: =>
    if @$el.find('.search-input input').val().trim() == ''
      @$el.find('.search-input').removeClass 'focus'

module.exports = VisualizationActions