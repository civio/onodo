#React     = require 'react'
#ReactDOM  = require 'react-dom'
#VisualizationGraphD3Component = require './../views/components/visualization-graph.cjsx'
VisualizationGraphCanvasView          = require './../views/visualization-graph-canvas-view.js'
VisualizationGraphConfigurationView   = require './../views/visualization-graph-configuration-view.js'
VisualizationGraphNavigationView      = require './../views/visualization-graph-navigation-view.js'

class VisualizationGraphView extends Backbone.View
  
  nodesSync:      false
  relationsSync:  false
  visualizationGraphViewCanvas:     null
  visualizationGraphConfiguration:  null
  visualizationGraphNavigation:     null

  initialize: ->
    console.log 'initialize GraphView', @collection
    @collection.nodes.once 'sync', @onNodesSync , @
    @collection.relations.once 'sync', @onRelationsSync , @
    $('.visualization-graph-menu-actions .configure').click @onShowPanelConfigure
    $('.visualization-graph-panel-configuration .close').click @onHidePanelConfigure

  onShowPanelConfigure: ->
    $('.visualization-graph-panel-configuration').addClass 'active'

  onHidePanelConfigure: ->
    $('.visualization-graph-panel-configuration').removeClass 'active'

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
    # Setup D3 Canvas
    @visualizationGraphCanvas = new VisualizationGraphCanvasView {el: @$el, data: @getDataFromCollection()}
    @visualizationGraphCanvas.render()
    # Setup Configuration Panel
    @visualizationGraphConfiguration = new VisualizationGraphConfigurationView
    @visualizationGraphConfiguration.setElement '.visualization-graph-panel-configuration'
    @visualizationGraphConfiguration.render()
    # Setup Nevigation Menu
    @visualizationGraphNavigation = new VisualizationGraphNavigationView
    @visualizationGraphNavigation.setElement '.visualization-graph-menu-navigation'
    @visualizationGraphNavigation.render()
    # Setup Events Listeners
    Backbone.on 'visualization.node.name', @onNodeChangeName, @
    Backbone.on 'visualization.node.description', @onNodeChangeDescription, @
    Backbone.on 'visualization.node.visible', @onNodeChangeVisible, @
    # Subscribe Config Panel Events
    Backbone.on 'visualization.config.toogleLabels', @onToogleLabels, @
    Backbone.on 'visualization.config.toogleNodesWithoutRelation', @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateParam', @onUpdateParam, @
    # Subscribe Navigation Events
    Backbone.on 'visualization.navigation.zoomin', @onZoomIn, @
    Backbone.on 'visualization.navigation.zoomout', @onZoomOut, @
    Backbone.on 'visualization.navigation.fullscreen', @onFullscreen, @

    #VisualizationGraphViewCanvas
    # ReactDOM.render(
    #   React.createElement(VisualizationGraphD3Component, {collection: @collection}),
    #   @$el.get(0)
    # )
    #ReactDOM.render React.createElement(VisualizationGraphComponent, {data: @collection.models}), @$el.get(0)
    return this

  resize: ->
    if @visualizationGraphCanvas
      @visualizationGraphCanvas.resize()

  onNodeChangeName: (e) ->
    @visualizationGraphCanvas.updateNodeName e.node.attributes, e.value

  onNodeChangeDescription: (e) ->  
    @visualizationGraphCanvas.updateNodeDescription e.node.attributes, e.value

  onNodeChangeVisible: (e) ->
    if e.value
      @visualizationGraphCanvas.showNode e.node.attributes
    else
      @visualizationGraphCanvas.hideNode e.node.attributes
    @visualizationGraphCanvas.updateLayout()

  onToogleLabels: (e) ->
    @visualizationGraphCanvas.toogleLabels e.value
  
  onToogleNodesWithoutRelation: (e) ->
    @visualizationGraphCanvas.toogleNodesWithoutRelation e.value

  onUpdateParam: (e) ->
    @visualizationGraphCanvas.updateForceLayoutParameter e.name, e.value

  onZoomIn: (e) ->
    @visualizationGraphCanvas.zoomIn()
    
  onZoomOut: (e) ->
    @visualizationGraphCanvas.zoomOut()

  onFullscreen: (e) ->
    @visualizationGraphCanvas.toogleFullscreen()


module.exports = VisualizationGraphView