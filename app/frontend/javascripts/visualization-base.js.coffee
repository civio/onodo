# Imports
Visualization                = require './models/visualization.js'
Node                         = require './models/node.js'
NodesCollection              = require './collections/nodes-collection.js'
RelationsCollection          = require './collections/relations-collection.js'
VisualizationCanvas          = require './views/visualization-canvas.js'
VisualizationNavigation      = require './views/visualization-navigation.js'
VisualizationActions         = require './views/visualization-actions.js'
VisualizationShare           = require './views/visualization-share.js'
VisualizationInfo            = require './views/visualization-info.js'

class VisualizationBase

  id:                         null
  edit:                       false
  nodes:                      null
  visualizationCanvas:        null
  visualizationNavigation:    null
  visualizationActions:       null
  visualizationShare:         null
  visualizationInfo:          null
  parameters: null
  parametersDefault: {
    nodesColor:         'solid-1'
    nodesColorColumn:   'type'
    nodesSize:          11
    nodesSizeColumn:    'relations'
    showNodesLabel:     1
    showNodesImage:     1
    relationsCurvature: 1
    relationsLineStyle: 0
    linkDistance:       100
    linkStrength:       -30
  }

  constructor: (_id) ->
    console.log 'setup visualization base'
    @id = _id
    # Setup Visualization Model
    @visualization      = new Visualization()
    # Setup Collections
    @nodes              = new NodesCollection()
    @relations          = new RelationsCollection()
    # Setup Views
    @visualizationCanvas         = new VisualizationCanvas()
    @visualizationNavigation     = new VisualizationNavigation()
    @visualizationActions        = new VisualizationActions {collection: @nodes}
    @visualizationShare          = new VisualizationShare()
    @visualizationInfo           = new VisualizationInfo()

  render: ->
    # force resize
    @resize()
    # fetch model & collections
    syncCounter = _.after 3, @onSync
    @visualization.fetch  {url: '/api/visualizations/'+@id,               success: syncCounter}
    @nodes.fetch          {url: '/api/visualizations/'+@id+'/nodes/',     success: syncCounter}
    @relations.fetch      {url: '/api/visualizations/'+@id+'/relations/', success: syncCounter}

  resize: =>
    if @visualizationCanvas and @visualizationCanvas.svg
      @visualizationCanvas.resize()

  onSync: =>
    # Setup visualization parameters
    @parameters = $.parseJSON @visualization.get('parameters')
    @setupParameters()
    # Setup VisualizationCanvas
    @visualizationCanvas.setup @getVisualizationCanvasData(@nodes.models, @relations.models), @parameters
    @visualizationCanvas.render()
    @visualizationActions.render()
    # Setup Visualization Events
    @setupVisualizationEvents()

  # Format data from nodes & relations collections for VisualizationCanvas
  getVisualizationCanvasData: ( nodes, relations ) ->
    data =
      nodes:      nodes.map     (d) -> return d.attributes
      relations:  relations.map (d) -> return d.attributes
    # Fix relations source & target index (based on 1 instead of 0)
    data.relations.forEach (d) ->
      d.source = d.source_id-1
      d.target = d.target_id-1
    return data

  # Parameters methods
  setupParameters: ->
    @parameters = @parameters || {}
    # setup parameters
    @parameters.nodesColor          = @parameters.nodesColor || @parametersDefault.nodesColor
    @parameters.nodesColorColumn    = @parameters.nodesColorColumn || @parametersDefault.nodesColorColumn
    @parameters.nodesSize           = @parameters.nodesSize || @parametersDefault.nodesSize
    @parameters.nodesSizeColumn     = @parameters.nodesSizeColumn || @parametersDefault.nodesSizeColumn
    @parameters.showNodesLabel      = if typeof @parameters.showNodesLabel != 'undefined' then @parameters.showNodesLabel else @parametersDefault.showNodesLabel
    @parameters.showNodesImage      = if typeof @parameters.showNodesImage != 'undefined' then @parameters.showNodesImage else @parametersDefault.showNodesImage
    @parameters.relationsCurvature  = @parameters.relationsCurvature || @parametersDefault.relationsCurvature
    @parameters.relationsLineStyle  = @parameters.relationsLineStyle || @parametersDefault.relationsLineStyle
    @parameters.linkDistance        = @parameters.linkDistance || @parametersDefault.linkDistance
    @parameters.linkStrength        = @parameters.linkStrength || @parametersDefault.linkStrength

  setupVisualizationEvents: ->
    # Subscribe VisualizationCanvas Events
    Backbone.on 'visualization.node.showInfo',         @onNodeShowInfo, @
    Backbone.on 'visualization.node.hideInfo',         @onNodeHideInfo, @
    # Subscribe Navigation Events
    Backbone.on 'visualization.navigation.zoomin',     @onZoomIn, @
    Backbone.on 'visualization.navigation.zoomout',    @onZoomOut, @
    Backbone.on 'visualization.navigation.fullscreen', @onFullscreen, @
    # Subscribe Actions Events
    Backbone.on 'visualization.actions.search',        @onNodeSearch, @
    # Trigger synced event for Stories
    Backbone.trigger 'visualization.synced'

  # Canvas Events
  onNodeShowInfo: (e) ->
    console.log 'onNodeShowInfo', typeof e.node
    node = @nodes.get(e.node)
    @visualizationCanvas.focusNode node
    @visualizationInfo.show node, @visualization.get('node_custom_fields')

  onNodeHideInfo: (e) ->
    @visualizationCanvas.unfocusNode()
    @visualizationInfo.hide()

  # Navigation Events
  onZoomIn: (e) ->
    @visualizationCanvas.zoomIn()
    
  onZoomOut: (e) ->
    @visualizationCanvas.zoomOut()

  onFullscreen: (e) ->
    $('body').toggleClass 'fullscreen'
    @resize()

  # Actions Events
  onNodeSearch: (e) =>
    @visualizationCanvas.onNodeOver e.node
    #@visualizationCanvas.centerNode e.node

module.exports = VisualizationBase