# Imports
NodesCollection              = require './collections/nodes-collection.js'
RelationsCollection          = require './collections/relations-collection.js'
VisualizationGraph           = require './views/visualization-graph.js'
VisualizationTableNodes      = require './views/visualization-table-nodes.js'
VisualizationTableRelations  = require './views/visualization-table-relations.js'

class VisualizationEdit

  mainHeaderHeight:             82
  visualizationHeaderHeight:    91
  tableHeaderHeight:            50

  id:                           null
  nodes:                        null
  visualizationGraph:           null
  visualizationTableNodes:      null
  visualizationTableRelations:  null
  $tableSelector:               null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    @id = _id
    # Setup Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    # Setup Views
    @visualizationTableNodes      = new VisualizationTableNodes {collection: @nodes}
    @visualizationTableRelations  = new VisualizationTableRelations {collection: @relations}
    @visualizationGraph           = new VisualizationGraph {collection: {nodes: @nodes, relations: @relations} }
    # Setup Table Selector
    $('#visualization-table-selector > li > a').click @updateTable
    

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: @mainHeaderHeight + @visualizationHeaderHeight

  updateTable: (e) =>
    e.preventDefault()
    if $(e.target).parent().hasClass('active')
      return
    console.log('updateTable', e)
    # Show tab
    $(e.target).tab('show')
    # Update table
    if $(e.target).attr('href') == '#nodes'
      @visualizationTableRelations.hide()
      @visualizationTableNodes.show()
    else
      @visualizationTableNodes.hide()
      @visualizationTableRelations.show()

  resize: =>
    console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - @mainHeaderHeight - @visualizationHeaderHeight - @tableHeaderHeight
    @visualizationGraph.$el.height graphHeight
    @visualizationGraph.resize()
    $('.visualization-table').css 'top', graphHeight + @visualizationHeaderHeight
    # TODO!!! Resize table to windowHeight -> We also need to resize HandsOnTable height
    #$('.visualization-table').height windowHeight
    $('.footer').css 'top', graphHeight + @visualizationHeaderHeight

  render: ->
    @setupAffix()   # setup affix bootstrap
    @resize()       # force resize
    # fetch collections
    @nodes.fetch {url: '/api/visualizations/'+@id+'/nodes/'}
    @relations.fetch {url: '/api/visualizations/'+@id+'/relations/'}

module.exports = VisualizationEdit;