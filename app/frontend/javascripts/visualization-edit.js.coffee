# Imports
NodesCollection              = require './collections/nodes-collection.js'
RelationsCollection          = require './collections/relations-collection.js'
VisualizationGraph           = require './views/visualization-graph.js'
VisualizationTableNodes      = require './views/visualization-table-nodes.js'
VisualizationTableRelations  = require './views/visualization-table-relations.js'

class VisualizationEdit

  mainHeaderHeight:             82
  visualizationHeaderHeight:    91
  tableHeaderHeight:            44

  id:                           null
  nodes:                        null
  visualizationGraph:           null
  visualizationTable:           null
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
    # Attach nodes to VisualizationTableRelations
    @visualizationTableRelations.setNodes @nodes
    # Setup Table Tab Selector
    $('#visualization-table-selector > li > a').click @updateTable
    # Setup visualization table
    @visualizationTable = $('.visualization-table')
    $('.visualization-table-scrollbar a').click (e) ->
      e.preventDefault()
      $('html, body').animate { scrollTop: $(document).height() }, 1000

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
    tableHeight = (windowHeight*0.5) + @tableHeaderHeight
    @visualizationGraph.$el.height graphHeight
    @visualizationGraph.resize()
    @visualizationTable.css 'top', graphHeight + @visualizationHeaderHeight
    @visualizationTable.height tableHeight
    @visualizationTableNodes.setSize tableHeight, @visualizationTable.offset().top
    @visualizationTableRelations.setSize tableHeight, @visualizationTable.offset().top
    #$('.footer').css 'top', graphHeight + @visualizationHeaderHeight

  render: ->
    @setupAffix()   # setup affix bootstrap
    @resize()       # force resize
    # fetch collections
    @nodes.fetch {url: '/api/visualizations/'+@id+'/nodes/'}
    @relations.fetch {url: '/api/visualizations/'+@id+'/relations/'}

module.exports = VisualizationEdit;