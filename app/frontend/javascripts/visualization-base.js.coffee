# Imports
Visualization                = require './models/visualization.js'
Node                         = require './models/node.js'
NodesCollection              = require './collections/nodes-collection.js'
RelationsCollection          = require './collections/relations-collection.js'
VisualizationCanvas          = require './views/visualization-canvas.js'
VisualizationNavigation      = require './views/visualization-navigation.js'
VisualizationActions         = require './views/visualization-actions.js'
VisualizationLegend          = require './views/visualization-legend.js'
VisualizationShare           = require './views/visualization-share.js'
VisualizationInfo            = require './views/visualization-info.js'

class VisualizationBase

  id:                         null
  edit:                       false
  nodes:                      null
  visualizationCanvas:        null
  visualizationLegend:        null
  visualizationNavigation:    null
  visualizationActions:       null
  visualizationShare:         null
  visualizationInfo:          null
  parameters: null
  parametersDefault: {
    nodesColor:             'qualitative'
    nodesColorColumn:       'node_type'
    nodesFixed:             false
    nodesSize:              1
    nodesSizeColumn:        'relations'
    showNodesLabel:         1
    showNodesLabelComplete: 0
    showNodesImage:         1
    showLegend:             1
    #relationsCurvature:     1
    relationsWidth:         0
    relationsWidthColumn:   null
    relationsLineStyle:     0
    linkDistance:           120
    linkStrength:           -30
  }

  constructor: (_id) ->
    @id = _id
    @setupData()
    # Setup Views
    @visualizationCanvas         = new VisualizationCanvas()
    @visualizationLegend         = new VisualizationLegend()
    @visualizationNavigation     = new VisualizationNavigation()
    @visualizationActions        = new VisualizationActions {collection: @nodes}
    @visualizationShare          = new VisualizationShare()
    @visualizationInfo           = new VisualizationInfo()

  setupData: ->
    # Setup Visualization Model
    @visualization      = new Visualization()
    # Setup Collections
    @nodes              = new NodesCollection()
    @relations          = new RelationsCollection()

  render: ->
    # force resize
    @resize()
    # fetch model & collections
    syncCounter = _.after 3, @onSync
    @visualization.fetch  {url: '/api/visualizations/'+@id,               success: syncCounter}
    @nodes.fetch          {url: '/api/visualizations/'+@id+'/nodes/',     success: syncCounter}
    @relations.fetch      {url: '/api/visualizations/'+@id+'/relations/', success: syncCounter}

  resize: =>
    if @visualizationCanvas and @visualizationCanvas.canvas
      @visualizationCanvas.resize()

  onSync: =>
    # Setup visualization parameters
    @parameters = $.parseJSON @visualization.get('parameters')
    @setupParameters()
    # Setup VisualizationCanvas
    @visualizationCanvas.setup @nodes, @relations, @parameters
    @visualizationCanvas.render()
    if @visualizationLegend
      @visualizationLegend.setup @parameters
      @visualizationLegend.render @visualizationCanvas.scale_nodes_size, @visualizationCanvas.scale_color
    @visualizationNavigation.render()
    @visualizationActions.render @parameters
    # Setup Visualization Events
    @bindVisualizationEvents()
    # Trigger synced event for Stories
    Backbone.trigger 'visualization.synced'

  # Parameters methods
  setupParameters: ->
    # setup dynamic default parameters (showNodesLabel)
    if @nodes.length > 150
      @parametersDefault.showNodesLabel = false
    @parameters = @parameters || {}
    # setup parameters
    @parameters.nodesColor              = @parameters.nodesColor || @parametersDefault.nodesColor
    @parameters.nodesColorColumn        = @parameters.nodesColorColumn || @parametersDefault.nodesColorColumn
    @parameters.nodesFixed              = @parameters.nodesFixed || @parametersDefault.nodesFixed
    @parameters.nodesSize               = @parameters.nodesSize || @parametersDefault.nodesSize
    @parameters.nodesSizeColumn         = @parameters.nodesSizeColumn || @parametersDefault.nodesSizeColumn
    @parameters.showNodesLabel          = if typeof @parameters.showNodesLabel != 'undefined' then @parameters.showNodesLabel else @parametersDefault.showNodesLabel
    @parameters.showNodesLabelComplete  = if typeof @parameters.showNodesLabelComplete != 'undefined' then @parameters.showNodesLabelComplete else @parametersDefault.showNodesLabelComplete
    @parameters.showNodesImage          = if typeof @parameters.showNodesImage != 'undefined' then @parameters.showNodesImage else @parametersDefault.showNodesImage
    @parameters.showLegend              = if typeof @parameters.showLegend != 'undefined' then @parameters.showLegend else @parametersDefault.showLegend
    @parameters.relationsCurvature      = @parameters.relationsCurvature || @parametersDefault.relationsCurvature
    @parameters.relationsWidth          = @parameters.relationsWidth || @parametersDefault.relationsWidth
    @parameters.relationsWidthColumn    = @parameters.relationsWidthColumn || @parametersDefault.relationsWidthColumn
    @parameters.relationsLineStyle      = @parameters.relationsLineStyle || @parametersDefault.relationsLineStyle
    @parameters.linkDistance            = @parameters.linkDistance || @parametersDefault.linkDistance
    @parameters.linkStrength            = @parameters.linkStrength || @parametersDefault.linkStrength

  bindVisualizationEvents: ->
    # Subscribe VisualizationCanvas Events
    Backbone.on 'visualization.node.showInfo',         @onNodeShowInfo, @
    Backbone.on 'visualization.node.hideInfo',         @onNodeHideInfo, @
    # Subscribe Navigation Events
    Backbone.on 'visualization.navigation.zoomin',     @onZoomIn, @
    Backbone.on 'visualization.navigation.zoomout',    @onZoomOut, @
    Backbone.on 'visualization.navigation.fullscreen', @onFullscreen, @
    # Subscribe Actions Events
    Backbone.on 'visualization.actions.search',        @onNodeSearch, @

  unbindVisualizationEvents: ->
    # Unsubscribe VisualizationCanvas Events
    Backbone.off 'visualization.node.showInfo'
    Backbone.off 'visualization.node.hideInfo'
    # Unsubscribe Navigation Events
    Backbone.off 'visualization.navigation.zoomin'
    Backbone.off 'visualization.navigation.zoomout'
    Backbone.off 'visualization.navigation.fullscreen'
    # Unsubscribe Actions Events
    Backbone.off 'visualization.actions.search'

  # Canvas Events
  onNodeShowInfo: (e) ->
    #console.log 'onNodeShowInfo', typeof e.node
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
    @visualizationCanvas.focusNode e.node
    #@visualizationCanvas.centerNode e.node

module.exports = VisualizationBase