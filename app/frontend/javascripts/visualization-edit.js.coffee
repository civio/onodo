# Imports
NodesCollection                   = require './collections/nodes-collection.js'
RelationsCollection               = require './collections/relations-collection.js'
VisualizationGraphView            = require './views/visualization-graph-view.js'
VisualizationTableNodesView       = require './views/visualization-table-nodes-view.js'
VisualizationTableRelationsView   = require './views/visualization-table-relations-view.js'

class VisualizationEdit

  id:                               null
  nodes:                            null
  visualizationGraphView:           null
  visualizationTableNodesView:      null
  visualizationTableRelationsView:  null
  $tableSelector:                   null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    @id = _id
    # Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    # Set Graph View
    @visualizationGraphView = new VisualizationGraphView {collection: {nodes: @nodes, relations: @relations} }
    @visualizationGraphView.setElement '.visualization-graph-component'
    # Set Table Nodes
    @visualizationTableNodesView = new VisualizationTableNodesView {collection: @nodes}
    @visualizationTableNodesView.setElement '.visualization-table-nodes'
    # Set Table Relations
    @visualizationTableRelationsView = new VisualizationTableRelationsView {collection: @relations}
    @visualizationTableRelationsView.setElement '.visualization-table-relations'
    # Setup Table Selector
    @$tableSelector = $('#visualization-table-selector .btn').click @updateTable

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: 50

  updateTable: (e) =>
    e.preventDefault()
    if $(e.target).hasClass('active')
      return
    console.log('updateTable', e)
    @$tableSelector
      .filter '.active'
      .removeClass 'active btn-primary'
      .addClass 'btn-default'
    $(e.target).addClass 'active btn-primary'
    if $(e.target).attr('href') == '#nodes'
      @visualizationTableRelationsView.hide()
      @visualizationTableNodesView.show()
    else
      @visualizationTableNodesView.hide()
      @visualizationTableRelationsView.show()


  resize: =>
    #console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    @visualizationGraphView.$el.height graphHeight
    $('.visualization-table').css 'top', graphHeight+64
    # $('.visualization-table').height( windowHeight - 64 );
    $('.footer').css 'top', graphHeight+64

  render: ->
    @setupAffix()   # setup affix bootstrap
    @resize()       # force resize
    # fetch collections
    @nodes.fetch {url: '/api/visualizations/'+@id+'/nodes/'}
    @relations.fetch {url: '/api/visualizations/'+@id+'/relations/'}

module.exports = VisualizationEdit;