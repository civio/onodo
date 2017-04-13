require 'typeahead.js/dist/typeahead.jquery.min.js'
Bloodhound = require 'typeahead.js/dist/bloodhound.min.js'

class VisualizationActions extends Backbone.View

  el:           '.visualization-graph-menu-actions'
  parameters:   null
  $search_form: null
  $share_panel: null
  $fix_nodes:   null

  initialize: ->
    @$share_panel = $('#visualization-share')
    @$search_form = @$el.find('.search-form input')
    @$fix_nodes   = @$el.find('.btn-fix-nodes')
    # Setup Share Panel Show/Hide
    @$el.find('.btn-share').click      @onPanelShareShow
    @$share_panel.find('.close').click @onPanelShareHide
    # Setup Search Input Events
    @$search_form
      .focusin @onSearchNodeFocus
      .focusout @onSearchNodeUnfocus
    # Setup Fix Nodes Events
    @$fix_nodes.click @onFixNodesClick

  render: (_parameters) ->
    @parameters = _parameters
    if @parameters.nodesFixed
      @$fix_nodes.addClass 'fixed'
    @setupTypehead()
    # show actions menu
    @$el.addClass 'visible'

  setupTypehead: ->
    # search only visible nodes
    data = @collection.models.filter (d) -> return d.get('visible')
    # constructs typeahead suggestion engine
    bloodhound = new Bloodhound {
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: data.map (d) -> return d.get('name')
    }
    # typeahead setup
    @$search_form.typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      },
      {
        source: bloodhound
      }).on 'typeahead:selected', @onSearchSelected

  updateSearchData: ->
    @$search_form.typeahead 'destroy'
    @setupTypehead()

  # Panel Share Events
  onPanelShareShow: =>
    @$share_panel.addClass 'active'

  onPanelShareHide: =>
    @$share_panel.removeClass 'active'

  # Search Node Events
  onSearchNodeFocus: =>
    @$search_form.parent().addClass 'focus'

  onSearchNodeUnfocus: =>
    if @$search_form.val().trim() == ''
      @$search_form.parent().removeClass 'focus'

  onSearchSelected: (e, value) =>
    node = @collection.findWhere({name: value})
    if node
      @$search_form.typeahead('val', '')
      # trigger visualization.actions.search event to force hover node
      Backbone.trigger 'visualization.actions.search', {node: node}
      # trigger visualization.node.showInfo event to show panel node info
      Backbone.trigger 'visualization.node.showInfo', {node: node.id}

  onFixNodesClick: =>
    @$fix_nodes.toggleClass 'fixed'
    Backbone.trigger 'visualization.actions.fixNodes', {value: !@parameters.nodesFixed}

module.exports = VisualizationActions