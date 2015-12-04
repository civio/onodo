# Imports
NodesCollection               = require './collections/nodes-collection.js'
RelationsCollection           = require './collections/relations-collection.js'
VisualizationGraph            = require './views/visualization-graph.js'
VisualizationTableNodes       = require './views/visualization-table-nodes.js'
VisualizationTableRelations   = require './views/visualization-table-relations.js'

class VisualizationShow

  id:                               null
  nodes:                            null
  visualizationGraph:           null
  visualizationTableNodes:      null
  visualizationTableRelations:  null
  $tableSelector:                   null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    @id = _id
    # Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    # Set Graph 
    @visualizationGraph = new VisualizationGraph {collection: {nodes: @nodes, relations: @relations} }
    @visualizationGraph.setElement '.visualization-graph-component'
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
    @visualizationGraph.$el.height graphHeight
    @visualizationGraph.resize()
    # $('.visualization-table').height( windowHeight - 64 );
    #$('.footer').css 'top', graphHeight+64

  render: ->
    @resize()       # force resize
    # fetch collections
    @nodes.fetch {url: '/api/visualizations/'+@id+'/nodes/'}
    @relations.fetch {url: '/api/visualizations/'+@id+'/relations/'}


module.exports = VisualizationShow