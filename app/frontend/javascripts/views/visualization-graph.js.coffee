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
    $('html, body').animate { scrollTop: 0 }, 600
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
    if @nodesSync and @relationsSync
      @render()

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

    # Subscribe Collection Events (handle Table changes)
    @collection.nodes.bind 'add',                 @onNodesAdd, @
    @collection.nodes.bind 'change:name',         @onNodeChangeName, @
    @collection.nodes.bind 'change:description',  @onNodeChangeDescription, @
    @collection.nodes.bind 'change:visible',      @onNodeChangeVisible, @
    @collection.nodes.bind 'remove',              @onNodesRemove, @
    #!!! We need to arr node_type changes
    #@collection.nodes.bind 'change:node_type',   @onNodeChangeType, @
    #@collection.relations.bind 'add',             @onRelationsChange, @
    @collection.relations.bind 'change:source_id',      @onRelationsChangeNode, @
    @collection.relations.bind 'change:target_id',      @onRelationsChangeNode, @
    @collection.relations.bind 'change:relation_type',  @onRelationsChangeType, @
    @collection.relations.bind 'change:direction',      @onRelationsChangeDirection, @
    @collection.relations.bind 'remove',                @onRelationsRemove, @
    # Subscribe Canvas Events
    Backbone.on 'visualization.node.showInfo',    @onNodeShowInfo, @
    Backbone.on 'visualization.node.hideInfo',    @onNodeHideInfo, @
    # Subscribe Table Events
    #Backbone.on 'visualization.node.create',      @onNodeCreate, @
    #Backbone.on 'visualization.node.name',        @onNodeChangeName, @
    #Backbone.on 'visualization.node.description', @onNodeChangeDescription, @
    #Backbone.on 'visualization.node.visible',     @onNodeChangeVisible, @
    # Subscribe Config Panel Events
    Backbone.on 'visualization.config.toogleLabels',                @onToogleLabels, @
    Backbone.on 'visualization.config.toogleNodesWithoutRelation',  @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateRelationsCurvature',    @onUpdateRelationsCurvature, @
    Backbone.on 'visualization.config.updateForceLayoutParam',      @onUpdateForceLayoutParam, @
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

  setOffset: (offset) ->
    @visualizationGraphCanvas.setOffset offset

  # Collections Events
  onNodesAdd: (node) ->
    # We need to wait until sync event to get node id
    @collection.nodes.once 'sync', (model) =>
      console.log 'onNodesAdd', model.id, model
      @visualizationGraphCanvas.addNode model.attributes
      @visualizationGraphCanvas.updateLayout()
    , @

  onNodeChangeName: (node) ->
    console.log 'onNodeChangeName', node.attributes.name
    # Update nodes labels
    @visualizationGraphCanvas.updateNodesLabels()
    # Update Panel Info name
    @updateGraphInfoNode node

  onNodeChangeDescription: (node) ->
    console.log 'onNodeChangeDescription', node.attributes.description
    # Update Panel Info description
    @updateGraphInfoNode node

  onNodeChangeVisible: (node) ->
    console.log 'onNodeChangeVisibe', node
    if node.attributes.visible
      @visualizationGraphCanvas.showNode node.attributes
    else
      @visualizationGraphCanvas.hideNode node.attributes
      # Hide Panel Info if visible for current node
      if @visualizationGraphInfo.isVisible() and @visualizationGraphInfo.node.id == node.id
        @visualizationGraphInfo.hide()
    @visualizationGraphCanvas.updateLayout()

  onNodesRemove: (node) ->
    console.log 'onNodesRemove', node.attributes.name
    @visualizationGraphCanvas.removeNode node.attributes
    @visualizationGraphCanvas.updateLayout()
    # Hide Panel Info if visible for current node
    if @visualizationGraphInfo.isVisible() and @visualizationGraphInfo.node.id == node.id
      @visualizationGraphInfo.hide()

  onRelationsChangeNode: (relation) ->
    console.log 'onRelationsChange', relation
    # check if we have both source_id and target_id
    if relation.attributes.source_id and relation.attributes.target_id
      # Remove relation if exist in graph
      @visualizationGraphCanvas.removeVisibleRelationData relation.attributes
      # Add relation
      @visualizationGraphCanvas.addRelation relation.attributes
      @visualizationGraphCanvas.updateLayout()

  onRelationsChangeType: (relation) ->
    console.log 'onRelationsChangeType', relation
    @visualizationGraphCanvas.updateRelationsLabels()

  onRelationsChangeDirection: (relation) ->
    @visualizationGraphCanvas.updateRelations()

  onRelationsRemove: (relation) ->
    @visualizationGraphCanvas.removeRelation relation.attributes
    @visualizationGraphCanvas.updateLayout()
  
  # Canvas Events
  onNodeShowInfo: (e) ->
    console.log 'show info', e.node
    @visualizationGraphCanvas.focusNode e.node
    @visualizationGraphInfo.show e.node

  onNodeHideInfo: (e) ->
    @visualizationGraphCanvas.unfocusNode()
    @visualizationGraphInfo.hide()

  # Config Panel Events
  onToogleLabels: (e) ->
    @visualizationGraphCanvas.toogleLabels e.value
  
  onToogleNodesWithoutRelation: (e) ->
    @visualizationGraphCanvas.toogleNodesWithoutRelation e.value

  onUpdateRelationsCurvature: (e) ->
    @visualizationGraphCanvas.updateRelationsCurvature e.value

  onUpdateForceLayoutParam: (e) ->
    @visualizationGraphCanvas.updateForceLayoutParameter e.name, e.value

  # Navigation Events
  onZoomIn: (e) ->
    @visualizationGraphCanvas.zoomIn()
    
  onZoomOut: (e) ->
    @visualizationGraphCanvas.zoomOut()

  onFullscreen: (e) ->
    $('body').toggleClass 'fullscreen'
    @resize()


  updateGraphInfoNode: (node) ->
    if @visualizationGraphInfo.isVisible() and @visualizationGraphInfo.node.id == node.id
      @visualizationGraphInfo.node = node
      @visualizationGraphInfo.render()


module.exports = VisualizationGraph