# Imports
NodesCollection                   = require './collections/nodes-collection.js'
RelationsCollection               = require './collections/relations-collection.js'
VisualizationGraphView            = require './views/visualization-graph-view.js'
VisualizationTableNodesView       = require './views/visualization-table-nodes-view.js'
VisualizationTableRelationsView   = require './views/visualization-table-relations-view.js'

class VisualizationEdit

  id:                           null
  nodes:                        null
  visualizationGraph:           null
  visualizationTableNodes:      null
  visualizationTableRelations:  null
  $tableSelector:               null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    @id = _id
    # Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    # Set Table Nodes
    @visualizationTableNodes = new VisualizationTableNodesView {collection: @nodes}
    @visualizationTableNodes.setElement '.visualization-table-nodes'
    # Set Table Relations
    @visualizationTableRelations = new VisualizationTableRelationsView {collection: @relations}
    @visualizationTableRelations.setElement '.visualization-table-relations'
    # Setup Table Selector
    @$tableSelector = $('#visualization-table-selector .btn').click @updateTable
    # Set Graph View
    @visualizationGraph = new VisualizationGraphView {collection: {nodes: @nodes, relations: @relations} }
    @visualizationGraph.setElement '.visualization-graph-component'

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
      @visualizationTableRelations.hide()
      @visualizationTableNodes.show()
    else
      @visualizationTableNodes.hide()
      @visualizationTableRelations.show()


  resize: =>
    console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    @visualizationGraph.$el.height graphHeight
    @visualizationGraph.resize()
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