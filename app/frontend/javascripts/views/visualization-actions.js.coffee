class VisualizationActions extends Backbone.View

  el:          '.visualization-graph-menu-actions'
  search_form: null
  share_panel: null
  
  initialize: ->
    @share_panel = $('#visualization-share')
    @search_form = @$el.find('.search-form')
    @render()

  render: -> 
    # Setup Share Panel Show/Hide
    @$el.find('.btn-share').click      @onPanelShareShow
    @share_panel.find('.close').click  @onPanelShareHide
    # Setup Search Input Events
    @search_form.find('input').focusin( @onSearchNodeFocus ).focusout( @onSearchNodeUnfocus )
    @search_form.submit (e) =>
      e.preventDefault()
      Backbone.trigger 'visualization.actions.search', {value: @search_form.find('input').val()}
    return this

  # Panel Share Events
  onPanelShareShow: =>
    @share_panel.addClass 'active'

  onPanelShareHide: =>
    @share_panel.removeClass 'active'

  # Search Node Events
  onSearchNodeFocus: =>
    @search_form.addClass 'focus'

  onSearchNodeUnfocus: =>
    if @search_form.find('input').val().trim() == ''
      @search_form.removeClass 'focus'

module.exports = VisualizationActions