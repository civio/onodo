#React     = require 'react'
#ReactDOM  = require 'react-dom'
#VisualizationGraphD3Component = require './../views/components/visualization-graph.cjsx'
VisualizationGraphViewCanvas  = require './../views/visualization-graph-view-canvas.js'

class VisualizationGraphView extends Backbone.View
  
  nodesSync:      false
  relationsSync:  false

  initialize: ->
    console.log 'initialize GraphView', @collection
    @collection.nodes.once 'sync', @onNodesSync , @
    @collection.relations.once 'sync', @onRelationsSync , @

  onNodesSync: (nodes) =>
    @nodesSync = true
    console.log 'onNodesSync'
    @collection.nodes.bind 'change', @onCollectionChange, @
    if @nodesSync and @relationsSync
      @render()

  onRelationsSync: (relations) =>
    @relationsSync = true
    console.log 'onRelationsSync'
    @collection.relations.bind 'change', @onCollectionChange, @
    if @nodesSync and @relationsSync
      @render()

  onCollectionChange: (e) =>
    console.log 'Collection has changed', e

  getDataFromCollection: ->
    data =
      nodes:      @collection.nodes.models.map((d) -> return d.attributes)
      relations:  @collection.relations.models.map((d) -> return d.attributes)
    # Fix relations source & target index (based on 1 instead of 0)
    data.relations.forEach (d) ->
      d.source = d.source_id-1
      d.target = d.target_id-1
    return data

  render: ->
    console.log 'render GraphView'
    visualizationGraphViewCanvas = new VisualizationGraphViewCanvas {el: @$el, data: @getDataFromCollection()}
    visualizationGraphViewCanvas.render()
    #visualizationGraphViewCanvas.setElement '.visualization-graph-component'
    #VisualizationGraphViewCanvas
    # ReactDOM.render(
    #   React.createElement(VisualizationGraphD3Component, {collection: @collection}),
    #   @$el.get(0)
    # )
    #ReactDOM.render React.createElement(VisualizationGraphComponent, {data: @collection.models}), @$el.get(0)
    return this

module.exports = VisualizationGraphView