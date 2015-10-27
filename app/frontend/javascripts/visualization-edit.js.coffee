# Imports
NodesCollection         = require './collections/nodes-collection.js'
VisualizationGraphView  = require './views/visualization-graph-view.js'
VisualizationTableView  = require './views/visualization-table-view.js'

class VisualizationEdit

  nodes:                  null
  visualizationGraphView: null
  visualizationTableView: null

  constructor: ->
    # Collection
    @nodes = new NodesCollection()
    # Views
    @visualizationGraphView = new VisualizationGraphView {collection: @nodes}
    @visualizationGraphView.setElement '.visualization-graph-component'
    @visualizationTableView = new VisualizationTableView {collection: @nodes}
    @visualizationTableView.setElement '.visualization-table-nodes'

  resize: =>
    #console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    @visualizationGraphView.$el.height graphHeight
    $('.visualization-table').css 'top', graphHeight+64
    # $('.visualization-table').height( windowHeight - 64 );
    $('.footer').css 'top', graphHeight+64

  render: ->
    @nodes.fetch()  # fetch nodes collection
    @resize()       # force resize

module.exports = VisualizationEdit;