#React     = require 'react'
#ReactDOM  = require 'react-dom'
#VisualizationGraphD3Component = require './../views/components/visualization-graph.cjsx'
VisualizationGraphCanvas          = require './../views/visualization-graph-canvas.js'
VisualizationGraphConfiguration   = require './../views/visualization-graph-configuration.js'
VisualizationGraphNavigation      = require './../views/visualization-graph-navigation.js'
VisualizationGraphInfo            = require './../views/visualization-graph-info.js'

class VisualizationGraph extends Backbone.View
  
  el:             '.visualization-graph-component'
  nodesSync:      false
  relationsSync:  false
  visualizationGraphCanvas:     null
  visualizationGraphConfiguration:  null
  visualizationGraphNavigation:     null

  initialize: ->
    console.log 'initialize Graph', @collection
    # Setup Colllection Events
    @collection.nodes.once      'sync', @onNodesSync , @
    @collection.relations.once  'sync', @onRelationsSync , @
    # Setup Configure Panel Show/Hide
    $('.visualization-graph-menu-actions .configure').click     @onPanelConfigureShow
    $('.visualization-graph-panel-configuration .close').click  @onPanelConfigureHide
    # Setup Share Panel Show/Hide
    $('.visualization-graph-menu-actions .btn-share').click         @onPanelShareShow
    $('#visualization-share .close').click                      @onPanelShareHide

  onPanelConfigureShow: ->
    $(this).blur()
    $('.visualization-graph-panel-configuration').addClass 'active'

  onPanelConfigureHide: ->
    $('.visualization-graph-panel-configuration').removeClass 'active'

  onPanelShareShow: ->
    console.log 'panel share show'
    $('#visualization-share').addClass 'active'

  onPanelShareHide: ->
    console.log 'panel share hide'
    $('#visualization-share').removeClass 'active'

  onNodesSync: (nodes) =>
    @nodesSync = true
    console.log 'onNodesSync'
    @collection.nodes.bind 'add',     @onNodesAdd, @
    @collection.nodes.bind 'change',  @onNodesChange, @
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
    console.log 'render Graph'
    # Setup Views
    @visualizationGraphCanvas         = new VisualizationGraphCanvas {el: @$el, data: @getDataFromCollection()}
    @visualizationGraphConfiguration  = new VisualizationGraphConfiguration
    @visualizationGraphNavigation     = new VisualizationGraphNavigation
    @visualizationGraphInfo           = new VisualizationGraphInfo
    # Setup Events Listeners
    # Canvas Events
    Backbone.on 'visualization.node.showInfo', @onNodeShowInfo, @
    Backbone.on 'visualization.node.hideInfo', @onNodeHideInfo, @
    # Table Events
    #Backbone.on 'visualization.node.create',      @onNodeCreate, @
    Backbone.on 'visualization.node.name',        @onNodeChangeName, @
    Backbone.on 'visualization.node.description', @onNodeChangeDescription, @
    Backbone.on 'visualization.node.visible',     @onNodeChangeVisible, @
    # Subscribe Config Panel Events
    Backbone.on 'visualization.config.toogleLabels',                @onToogleLabels, @
    Backbone.on 'visualization.config.toogleNodesWithoutRelation',  @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateParam',                 @onUpdateParam, @
    # Subscribe Navigation Events
    Backbone.on 'visualization.navigation.zoomin',      @onZoomIn, @
    Backbone.on 'visualization.navigation.zoomout',     @onZoomOut, @
    Backbone.on 'visualization.navigation.fullscreen',  @onFullscreen, @

  resize: ->
    if @visualizationGraphCanvas
      @visualizationGraphCanvas.resize()


  # Collections Events
  onNodesAdd: (node) ->
    # We need to wait until sync event to get node id
    @collection.nodes.once 'sync', (model) =>
      @visualizationGraphCanvas.addNode {id: model.id}
      @visualizationGraphCanvas.updateLayout()
      # TODO!!! Set id & visible at table nodes view
    , @

  # Canvas Events
  onNodeShowInfo: (e) ->
    console.log 'show info', e.node
    @visualizationGraphCanvas.focusNode e.node
    @visualizationGraphInfo.show e.node

  onNodeHideInfo: (e) ->
    @visualizationGraphCanvas.unfocusNode()
    @visualizationGraphInfo.hide()

  # Table Events
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


module.exports = VisualizationGraph