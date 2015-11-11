# Imports
NodesCollection                   = require './collections/nodes-collection.js'
RelationsCollection               = require './collections/relations-collection.js'
VisualizationGraphView            = require './views/visualization-graph-view.js'
VisualizationTableNodesView       = require './views/visualization-table-nodes-view.js'
VisualizationTableRelationsView   = require './views/visualization-table-relations-view.js'

class VisualizationShow

  nodes:                            null
  visualizationGraphView:           null
  visualizationTableNodesView:      null
  visualizationTableRelationsView:  null
  $tableSelector:                   null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    # Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    @nodes.url      = '/api/visualizations/'+_id+'/nodes/';
    @relations.url  = '/api/visualizations/'+_id+'/relations/';
    # Set Graph View
    @visualizationGraphView = new VisualizationGraphView {collection: @nodes}
    @visualizationGraphView.setElement '.visualization-graph-component'

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: 50

  resize: =>
    #console.log 'resize!'
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    @visualizationGraphView.$el.height graphHeight
    # $('.visualization-table').height( windowHeight - 64 );
    #$('.footer').css 'top', graphHeight+64

  render: ->
    #@setupAffix()   # setup affix bootstrap
    @resize()       # force resize
    # fetch collections
    @nodes.fetch()
    @relations.fetch()

module.exports = VisualizationShow