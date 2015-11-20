# Imports
NodesCollection                   = require './collections/nodes-collection.js'
RelationsCollection               = require './collections/relations-collection.js'
VisualizationGraphView            = require './views/visualization-graph-view.js'
VisualizationTableNodesView       = require './views/visualization-table-nodes-view.js'
VisualizationTableRelationsView   = require './views/visualization-table-relations-view.js'

class VisualizationShow

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
    # Setup Table Selector
    @$tableSelector = $('#visualization-table-selector .btn').click @updateTable

  updateTable: (e) =>
    e.preventDefault()
    if $(e.target).hasClass('active')
      return
    @$tableSelector
      .filter '.active'
      .removeClass 'active btn-primary'
      .addClass 'btn-default'
    $(e.target).addClass 'active btn-primary'
    if $(e.target).attr('href') == '#nodes'
      $('.visualization-table-nodes').show()
      $('.visualization-table-relations').hide()
    else
      $('.visualization-table-nodes').hide()
      $('.visualization-table-relations').show()

  resize: =>
    #console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    @visualizationGraphView.$el.height graphHeight
    # $('.visualization-table').height( windowHeight - 64 );
    #$('.footer').css 'top', graphHeight+64

  render: ->
    @resize()       # force resize
    # fetch collections
    @nodes.fetch {url: '/api/visualizations/'+@id+'/nodes/'}
    @relations.fetch {url: '/api/visualizations/'+@id+'/relations/'}


module.exports = VisualizationShow