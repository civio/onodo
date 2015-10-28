# Imports
NodesCollection               = require './collections/nodes-collection.js'
VisualizationGraphView        = require './views/visualization-graph-view.js'
VisualizationTableNodesView   = require './views/visualization-table-nodes-view.js'

class VisualizationEdit

  nodes:                        null
  visualizationGraphView:       null
  visualizationTableNodesView:  null

  constructor: ->
    # Collection
    @nodes = new NodesCollection()
    # Views
    @visualizationGraphView = new VisualizationGraphView {collection: @nodes}
    @visualizationGraphView.setElement '.visualization-graph-component'
    @visualizationTableNodesView = new VisualizationTableNodesView {collection: @nodes}
    @visualizationTableNodesView.setElement '.visualization-table-nodes'

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: 50

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
    @nodes.fetch()  # fetch nodes collection

module.exports = VisualizationEdit;