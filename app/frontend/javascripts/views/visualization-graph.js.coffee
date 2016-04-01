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
    $('.visualization-graph-menu-actions .btn-configure').click @onPanelConfigureShow
    $('.visualization-graph-panel-configuration .close').click  @onPanelConfigureHide
    # Setup Share Panel Show/Hide
    $('.visualization-graph-menu-actions .btn-share').click     @onPanelShareShow
    $('#visualization-share .close').click                      @onPanelShareHide
    # Initial setup size
    @resize()

  onPanelConfigureShow: ->
    $(this).blur()
    $('.visualization-graph-panel-configuration').addClass 'active'

  onPanelConfigureHide: ->
    $('.visualization-graph-panel-configuration').removeClass 'active'

  onPanelShareShow: ->
    $('#visualization-share').addClass 'active'

  onPanelShareHide: ->
    $('#visualization-share').removeClass 'active'

  onNodesSync: (nodes) =>
    @nodesSync = true
    console.log 'onNodesSync'
    if @nodesSync and @relationsSync
      @render()
  

  onRelationsSync: (relations) =>
    @relationsSync = true
    console.log 'onRelationsSync'
    @collection.relations.bind 'change', @onRelationsChange, @
    if @nodesSync and @relationsSync
      @render()

  onNodesChange: (e, b) =>
    console.log 'Nodes has changed', e, b, e.changed
    # model.hasChangedmodel('prop')

  onRelationsChange: (e) =>
    console.log 'Relations has changed', e

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

    # Collection Events (handle Table changes)
    @collection.nodes.bind 'add',                 @onNodesAdd, @
    @collection.nodes.bind 'change:name',         @onNodeChangeName, @
    @collection.nodes.bind 'change:description',  @onNodeChangeDescription, @
    @collection.nodes.bind 'change:visible',      @onNodeChangeVisible, @
    #!!! We need to arr node_type changes
    #@collection.nodes.bind 'change:node_type',   @onNodeChangeType, @
    # Canvas Events
    Backbone.on 'visualization.node.showInfo',    @onNodeShowInfo, @
    Backbone.on 'visualization.node.hideInfo',    @onNodeHideInfo, @
    # Table Events
    #Backbone.on 'visualization.node.create',      @onNodeCreate, @
    #Backbone.on 'visualization.node.name',        @onNodeChangeName, @
    #Backbone.on 'visualization.node.description', @onNodeChangeDescription, @
    #Backbone.on 'visualization.node.visible',     @onNodeChangeVisible, @
    # Subscribe Config Panel Events
    Backbone.on 'visualization.config.toogleLabels',                @onToogleLabels, @
    Backbone.on 'visualization.config.toogleNodesWithoutRelation',  @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateParam',                 @onUpdateParam, @
    # Subscribe Navigation Events
    Backbone.on 'visualization.navigation.zoomin',      @onZoomIn, @
    Backbone.on 'visualization.navigation.zoomout',     @onZoomOut, @
    Backbone.on 'visualization.navigation.fullscreen',  @onFullscreen, @

  resize: ->
    # update container height
    h = if $('body').hasClass('fullscreen') then $(window).height() else $(window).height() - 50 - 64 - 64
    @$el.height h
    if @visualizationGraphCanvas
      @visualizationGraphCanvas.resize()


  # Collections Events
  onNodesAdd: (node) ->
    # We need to wait until sync event to get node id
    @collection.nodes.once 'sync', (model) =>
      console.log 'onNodesAdd', model.id, model
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
    console.log 'onNodeChangeName', e, e.attributes.name
    @visualizationGraphCanvas.updateNodeName e.attributes, e.attributes.name

  onNodeChangeDescription: (e) ->
    console.log 'onNodeChangeDescription', e, e.attributes.description
    @visualizationGraphCanvas.updateNodeDescription e.attributes, e.attributes.description

  onNodeChangeVisible: (e) ->
    console.log '--- onNodeChangeVisible', e
    if e.attributes.visible
      @visualizationGraphCanvas.showNode e.attributes
    else
      @visualizationGraphCanvas.hideNode e.attributes
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
    $('body').toggleClass 'fullscreen'
    @resize()


module.exports = VisualizationGraph