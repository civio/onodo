d3 = require '../dist/d3'

class VisualizationCanvasBase extends Backbone.View

  el: '.visualization-graph-component' 

  COLOR_SOLID:
    'solid-1': '#ef9387'
    'solid-2': '#fccf80'
    'solid-3': '#fee378'
    'solid-4': '#d9d070'
    'solid-5': '#82a389'
    'solid-6': '#87948f'
    'solid-7': '#89b5df'
    'solid-8': '#aebedf'
    'solid-9': '#c6a1bc'
    'solid-10': '#f1b6ae'
    'solid-11': '#a8a6a0'
    'solid-12': '#e0deda'
  COLOR_QUALITATIVE:  ['#88b5df', '#fbcf80', '#82a288','#ffebad', '#c5a0bb', '#dfdeda', '#a8a69f', '#ee9286', '#d9d06f', '#f0b6ad']
  COLOR_QUANTITATIVE: ['#fff0c2', '#ffe795', '#fedf69', '#fed63c', '#b5ba7c', '#6d9ebb', '#2482fb', '#2b64c5', '#31458f', '#382759']

  canvas:                 null
  data:                   null
  data_nodes:             []
  data_nodes_map:         d3.map()
  data_relations:         []
  data_relations_visibles:[]
  nodes:                  null
  nodes_labels:           null
  relations:              null
  relations_labels:       null
  force:                  null
  forceDrag:              null
  forceLink:              null
  forceManyBody:          null
  linkedByIndex:          {}
  parameters:             null
  color_scale:            null
  node_active:            null
  node_hovered:           null
  scale_nodes_size:       null
  scale_labels_size:      null
  # Viewport object to store drag/zoom values
  viewport:
    width: 0
    height: 0
    center:
      x: 0
      y: 0
    origin:
      x: 0
      y: 0
    x: 0
    y: 0
    dx: 0
    dy: 0
    offsetnode:
      x: 0
      y: 0
    drag:
      x: 0
      y: 0
    scale: 1
    translate:
      x: 0
      y: 0


  setup: (_data, _parameters) ->
    @parameters = _parameters

    @setupData _data

    @setupViewport()

    @setupForce()

    # Setup Canvas or SVG
    @setupCanvas()

    # if nodesSize = 1, set nodes size
    if @parameters.nodesSize == 1
      # set relations attribute in nodes
      if @parameters.nodesSizeColumn == 'relations'
        @setNodesRelations()
      @setScaleNodesSize()
  
    # Translate svg
    @rescale()

    # Remove loading class
    @$el.removeClass 'loading'

    # a FPS meter
    fpsMeter = d3.select(@el).append('div')
      .style 'font-family', 'monospace'
      .style 'position', 'absolute'
      .style 'top', '0'
      .style 'padding', '8px'
      .style 'background', 'black'
      .style 'color', 'white'
    ticks = []
    d3.timer (t) ->
      ticks.push t
      if ticks.length > 15
        ticks.shift()
      avgFrameLength = (ticks[ticks.length-1] - ticks[0])/ticks.length
      fpsMeter.html Math.round(1/avgFrameLength*1000) + ' fps'


  setupData: (data) ->
    @data_nodes              = []
    @data_relations          = []
    @data_relations_visibles = []

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d
      # force empties node_types to null to avoid 2 non-defined types 
      if d.node_type == ''
        d.node_type = null

    # Setup color scale
    @setColorScale()

    # Setup Relations: change relations source & target N based id to 0 based ids & setup linkedByIndex object
    data.relations.forEach (d) =>
      # Set source & target as nodes objetcs instead of index number
      d.source = @getNodeById d.source_id
      d.target = @getNodeById d.target_id
      d.state = 0
      d.color = '#cccccc'
      # Add all relations to data_relations array
      @data_relations.push d
      # Add relation to data_relations_visibles array if both nodes exist and are visibles
      if d.source and d.target and d.source.visible and d.target.visible
        @data_relations_visibles.push d
        @addRelationToLinkedByIndex d.source_id, d.target_id

    # Add linkindex to relations
    #@setLinkIndex()

    #console.log 'current nodes', @data_nodes
    #console.log 'current relations', @data_relations_visibles


  setupViewport: ->
    @viewport.width     = @$el.width()|0
    @viewport.height    = @$el.height()|0
    @viewport.center.x  = (@$el.width()*0.5)|0
    @viewport.center.y  = (@$el.height()*0.5)|0

  setupForce: ->
    # Setup force
    @forceLink = d3.forceLink()
      .id       (d) -> return d.id
      .distance ()  => return @parameters.linkDistance

    @forceManyBody = d3.forceManyBody()
      # (https://github.com/d3/d3-force#manyBody_strength)
      .strength () => return @parameters.linkStrength
      # set maximum distance between nodes over which this force is considered
      # (https://github.com/d3/d3-force#manyBody_distanceMax)
      .distanceMax 500
      #.theta        @parameters.theta

    @force = d3.forceSimulation()
      .force 'link',    @forceLink
      .force 'charge',  @forceManyBody
      .force 'center',  d3.forceCenter(0,0)
      .on    'tick',    @onTick
      #.stop()

    # Reduce number of force ticks until the system freeze
    # (https://github.com/d3/d3-force#simulation_alphaDecay)
    @force.alphaDecay 0.03

    # @force = d3.layout.force()
    #   .linkDistance @parameters.linkDistance
    #   .linkStrength @parameters.linkStrength
    #   .friction     @parameters.friction
    #   .charge       @parameters.charge
    #   .theta        @parameters.theta
    #   .gravity      @parameters.gravity
    #   .size         [@viewport.width, @viewport.height]
    #   .on           'tick', @onTick

    @forceDrag = d3.drag()
      .on('start',  @onNodeDragStart)
      .on('drag',   @onNodeDragged)
      .on('end',    @onNodeDragEnd)

  # Override with Canvas or SVG
  setupCanvas: ->

  # Override with Canvas or SVG clear
  clear: ->
    # Add loading class
    @$el.addClass 'loading'


  render: ( restarForce ) ->
    console.log 'render', restarForce
    @updateRelations()
    @updateNodes()
    @updateNodesLabels()
    @updateForce restarForce

  # Override with Canvas or SVG updateNodes
  updateNodes: ->

  # Override with Canvas or SVG updateRelations
  updateRelations: ->
  
  # Override with Canvas or SVG updateNodesLabels
  updateNodesLabels: ->
    
  # Override with Canvas or SVG updateNodesLabels
  updateRelationsLabels: (data) ->

  updateForce: (restarForce) ->
    # update force nodes & links
    @force.nodes(@data_nodes)
    @force.force('link').links(@data_relations_visibles)
    # restart force
    if restarForce
      @force.alpha(0.3).restart()
    ###
    # Run statci force layout https://bl.ocks.org/mbostock/1667139
    ticks = Math.ceil(Math.log(@force.alphaMin()) / Math.log(1 - @force.alphaDecay()))
    for i in [0...ticks]
      @force.tick()
    @onTick()
    ###

  # Used in app-visualization-demo & visualization-story
  updateData: (nodes, relations) ->
    # console.log 'canvas current Data', @data_nodes, @data_relations
    # Setup disable values in nodes
    @data_nodes.forEach (node) ->
      node.disabled = nodes.indexOf(node.id) == -1
    # Setup disable values in relations
    @data_relations_visibles.forEach (relation) ->
      relation.disabled = relations.indexOf(relation.id) == -1    

  addNodeData: (node) ->
    # check if node is present in @data_nodes
    #console.log 'addNodeData', node.id, node
    if node
      @data_nodes_map.set node.id, node
      @data_nodes.push node

  addRelationToLinkedByIndex: (source, target) ->
    # count number of relations between 2 nodes
    @linkedByIndex[source+','+target] = ++@linkedByIndex[source+','+target] || 1

  # Chekcout this!!! We don't use it
  # Add a linkindex property to relations
  # Based on https://github.com/zhanghuancs/D3.js-Node-MultiLinks-Node
  setLinkIndex: ->
    # Sort relations
    @data_relations_visibles.sort (a,b) ->
      if a.source_id > b.source_id
        return 1
      else if a.source_id < b.source_id
        return -1
      else 
        if a.target_id > b.target_id
          return 1
        else if a.target_id < b.target_id
          return -1
        else
          return 0
    # set linkindex attr
    @data_relations_visibles.forEach (relation, i) =>
      if i != 0 && @data_relations_visibles[i].source_id == @data_relations_visibles[i-1].source_id && @data_relations_visibles[i].target_id == @data_relations_visibles[i-1].target_id
        @data_relations_visibles[i].linkindex = @data_relations_visibles[i-1].linkindex + 1
      else
        @data_relations_visibles[i].linkindex = 1

  sortNodes: (a, b) ->
    if a.size > b.size
      return 1
    else if a.size < b.size
      return -1
    else
      return 0

  sortRelations: (a, b) ->
    if a.state > b.state
      return 1
    else if a.state < b.state
      return -1
    else
      return 0

  setColorScale: ->
    if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      color_scale_domain = @data_nodes.map (d) => return d[@parameters.nodesColorColumn]
      if @parameters.nodesColor == 'qualitative' 
        @color_scale = d3.scaleOrdinal().range @COLOR_QUALITATIVE
        @color_scale.domain _.uniq(color_scale_domain)
        #console.log 'color_scale_domain', _.uniq(color_scale_domain)
      else
        @color_scale = d3.scaleQuantize().range @COLOR_QUANTITATIVE
        # get max scale value avoiding undefined result
        color_scale_max = d3.max(color_scale_domain)
        unless color_scale_max
          color_scale_max = 0
        @color_scale.domain [0, color_scale_max]
        #console.log 'color_scale_domain', d3.max(color_scale_domain)
      # @color_scale = d3.scaleViridis()
      #   .domain([d3.max(color_scale_domain), 0])


  # Resize Methods
  # ---------------

  resize: ->
    #console.log 'VisualizationGraphCanvas resize'
    # Update Viewport attributes
    @viewport.width     = @$el.width()|0
    @viewport.height    = @$el.height()|0
    @viewport.origin.x  = ((@$el.width()*0.5) - @viewport.center.x)|0
    @viewport.origin.y  = ((@$el.height()*0.5) - @viewport.center.y)|0

    # Update canvas
    @canvas.attr 'width', @viewport.width
    @canvas.attr 'height', @viewport.height
    
    @rescale()
    # Update force size
    #@force.size [@viewport.width, @viewport.height] 


  # Override with Canvas or SVG rescale
  rescale: ->
   
  # Override with Canvas or SVG rescaleTransition
  rescaleTransition: ->
    

  # Events Methods
  # ---------------

  # Override with Canvas or SVG tick Function
  onTick: =>
  

  # Auxiliar Methods
  # ----------------

  getNodeById: (id) ->
    return @data_nodes_map.get id

  areNodesRelated: (a, b) ->
    return @linkedByIndex[a.id + ',' + b.id] || @linkedByIndex[b.id + ',' + a.id] || a.id == b.id

  setNodeSize: (d) ->
    # fixed nodes size 
    if @parameters.nodesSize != 1
      d.size = @parameters.nodesSize
    # nodes size based on number of relations or custom_fields
    else
      val = if d[@parameters.nodesSizeColumn] then d[@parameters.nodesSizeColumn] else 0
      d.size = @scale_nodes_size val

  setNodesRelations: =>
    # initialize relations attribute for each node with zero value
    @data_nodes.forEach (d) =>
      d.relations = 0
    # increment relation attributes for each relation
    @data_relations_visibles.forEach (d) =>
      d.source.relations += 1
      d.target.relations += 1
    
  setScaleNodesSize: =>
    # set node size scale
    if @data_nodes.length > 0
      maxValue = d3.max @data_nodes, (d) => return d[@parameters.nodesSizeColumn]
    else 
      maxValue = 0
    # avoid undefined values
    unless maxValue
      maxValue = 0
    # set nodes size scale
    @scale_nodes_size = d3.scaleLinear()
      .domain [0, maxValue]
      .range [5, 20]
    # set labels size scale
    @scale_labels_size = d3.scaleQuantize()
      .domain [0, maxValue]
      .range [0, 1, 2, 3]

  getImage: (d) ->
    # if image is defined and is an object with image.small.url attribute get that
    if d.image and d.image.small.url
      d.image.small.url
    # if image is defined but is a string get the string
    else if typeof d.image == 'string'
      d.image
    else
      null


module.exports = VisualizationCanvasBase