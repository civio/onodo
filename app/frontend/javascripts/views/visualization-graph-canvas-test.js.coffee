d3       = require 'd3'

class VisualizationGraphCanvasTest extends Backbone.View

  COLORS: {
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
    'quantitative-1': '#382759'
    'quantitative-2': '#31458f'
    'quantitative-3': '#2b64c5'
    'quantitative-4': '#2482fb'
    'quantitative-5': '#6d9ebb'
    'quantitative-6': '#b5ba7c'
    'quantitative-7': '#fed63c'
    'quantitative-8': '#fedf69'
    'quantitative-9': '#ffe795'
    'quantitative-10': '#fff0c2'
  }

  COLOR_QUALITATIVE:  null
  COLOR_QUANTITATIVE: null

  svg:                    null
  defs:                   null
  container:              null
  color:                  null
  data:                   null
  data_nodes:             []
  data_nodes_map:         d3.map()
  data_relations:         []
  data_relations_visibles:[]
  nodes_cont:             null
  nodes_labels_cont:      null
  relations_cont:         null
  relations_labels_cont:  null
  nodes:                  null
  nodes_labels:           null
  relations:              null
  relations_labels:       null
  force:                  null
  forceDrag:              null
  linkedByIndex:          {}
  parameters:             null
  nodes_relations_size:   null
  node_active:            null
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
    offsetx: 0
    offsety: 0
    drag:
      x: 0
      y: 0
    scale: 1

  initialize: (options) ->

    # setup colors scales
    @COLOR_QUALITATIVE = [
      @COLORS['solid-3']
      @COLORS['solid-7']
      @COLORS['solid-1']
      @COLORS['solid-5']
      @COLORS['solid-2']
      @COLORS['solid-8']
      @COLORS['solid-4']
      @COLORS['solid-9']
      @COLORS['solid-6']
      @COLORS['solid-10']
      @COLORS['solid-11']
      @COLORS['solid-12']
    ]
    @COLOR_QUANTITATIVE = [
      @COLORS['quantitative-1']
      @COLORS['quantitative-2']
      @COLORS['quantitative-3']
      @COLORS['quantitative-4']
      @COLORS['quantitative-5']
      @COLORS['quantitative-6']
      @COLORS['quantitative-7']
      @COLORS['quantitative-8']
      @COLORS['quantitative-9']
      @COLORS['quantitative-10']
    ]

    # Setup color scale
    @colorQualitativeScale  = d3.scaleOrdinal().range @COLOR_QUALITATIVE
    @colorQuantitativeScale = d3.scaleOrdinal().range @COLOR_QUANTITATIVE

  setup: (_data, _parameters) ->

    console.log 'canvas set Data'

    @parameters = _parameters

    # Setup Data
    @initializeData _data

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x  = @viewport.width*0.5
    @viewport.center.y  = @viewport.height*0.5

    # Setup force
    forceLink = d3.forceLink()
      .id       (d) -> return d.id
      .distance ()  => return @parameters.linkDistance

    forceManyBody = d3.forceManyBody()
      # (https://github.com/d3/d3-force#manyBody_strength)
      .strength () => console.log('strength', @parameters.linkStrength); return @parameters.linkStrength
      # set maximum distance between nodes over which this force is considered
      # (https://github.com/d3/d3-force#manyBody_distanceMax)
      .distanceMax 500
      #.theta        @parameters.theta

    @force = d3.forceSimulation()
      .force 'link',    forceLink
      .force 'charge',  forceManyBody
      .force 'center',  d3.forceCenter(@viewport.center.x, @viewport.center.y)
      .on    'tick',    @onTick

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

    svgDrag = d3.drag()
      .on('start',  @onCanvasDragStart)
      .on('drag',   @onCanvasDragged)
      .on('end',    @onCanvasDragEnd)

    # Setup SVG
    @svg = d3.select('svg')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      .call svgDrag

    # Define Arrow Markers
    @defs = @svg.append('svg:defs')
    # Setup arrow end
    @defs.append('svg:marker')
        .attr 'id', 'arrow-end'
        .attr 'class', 'arrow-marker'
        .attr 'viewBox', '-8 -10 8 20'
        .attr 'refX', 2
        .attr 'refY', 0
        .attr 'markerWidth', 10
        .attr 'markerHeight', 10
        .attr 'orient', 'auto'
      .append 'svg:path'
        .attr 'd', 'M -10 -8 L 0 0 L -10 8'
    # Setup arrow start
    @defs.append('svg:marker')
        .attr 'id', 'arrow-start'
        .attr 'class', 'arrow-marker'
        .attr 'viewBox', '0 -10 8 20'
        .attr 'refX', -2
        .attr 'refY', 0
        .attr 'markerWidth', 10
        .attr 'markerHeight', 10
        .attr 'orient', 'auto'
      .append 'svg:path'
        .attr 'd', 'M 10 -8 L 0 0 L 10 8'

    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()  # initialize nodes_relations_size array

    # Setup containers
    @container             = @svg.append('g')
    @relations_cont        = @container.append('g').attr('class', 'relations-cont '+@getRelationsLineStyle(@parameters.relationsLineStyle))
    @nodes_cont            = @container.append('g').attr('class', 'nodes-cont')
    @relations_labels_cont = @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_labels_cont     = @container.append('g').attr('class', 'nodes-labels-cont')
    
    # Translate svg
    @rescale()

  initializeData: (data) ->

    console.log 'initializeData'

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d

    # Setup color ordinal scale domain
    @colorQualitativeScale.domain   data.nodes.map( (d) -> d.node_type )
    @colorQuantitativeScale.domain  data.nodes.map( (d) -> d.node_type )

    # Setup Relations: change relations source & target N based id to 0 based ids & setup linkedByIndex object
    data.relations.forEach (d) =>
      # Set source & target as nodes objetcs instead of index number
      d.source = @getNodeById d.source_id
      d.target = @getNodeById d.target_id
      # Add all relations to data_relations array
      @data_relations.push d
      # Add relation to data_relations_visibles array if both nodes exist and are visibles
      if d.source and d.target and d.source.visible and d.target.visible
        @data_relations_visibles.push d
        @addRelationToLinkedByIndex d.source_id, d.target_id

    # Add linkindex to relations
    #@setLinkIndex()

    console.log 'current nodes', @data_nodes
    console.log 'current relations', @data_relations_visibles

  render: ( restarForce ) ->
    console.log 'render canvas'
    @updateImages()
    @updateRelations()
    @updateNodes()
    @updateNodesLabels()
    @updateForce restarForce

  updateImages: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    patterns = @defs.selectAll('filter').data(@data_nodes.filter (d) -> return d.image != null)

    # EXIT old elements not present in new data
    patterns.exit().remove()

    # UPDATE old elements present in new data
    patterns.attr('id', (d) -> return 'node-pattern-'+d.id)
      .selectAll('image')
        .attr('xlink:href', (d) -> return d.image.small.url)
    
    # ENTER new elements present in new data.
    patterns.enter().append('pattern')
      .attr('id', (d) -> return 'node-pattern-'+d.id)
      .attr('x', '0')
      .attr('y', '0')
      .attr('width', '100%')
      .attr('height', '100%')
      .attr('viewBox', '0 0 30 30')
      .append('image')
        .attr('x', '0')
        .attr('y', '0')
        .attr('width', '30')
        .attr('height', '30')
        .attr('xlink:href', (d) -> return d.image.small.url)

  updateNodes: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes = @nodes_cont.selectAll('.node').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes.exit().remove()

    # UPDATE old elements present in new data
    @nodes
      .attr 'id',       (d) -> return 'node-'+d.id
      .attr 'class',    (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       @getNodeSize
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeColor

    # ENTER new elements present in new data.
    @nodes.enter().append('circle')
      .attr  'id',      (d) -> return 'node-'+d.id
      .attr  'class',   (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       @getNodeSize
      # set position at viewport center
      .attr  'cx',      @viewport.center.x
      .attr  'cy',      @viewport.center.y
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeColor
      .on   'mouseover',  @onNodeOver
      .on   'mouseout',   @onNodeOut
      .on   'click',      @onNodeClick
      .on   'dblclick',   @onNodeDoubleClick
      .call @forceDrag

    @nodes = @nodes_cont.selectAll('.node')

  updateRelations: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @relations = @relations_cont.selectAll('.relation').data(@data_relations_visibles)

    # EXIT old elements not present in new data
    @relations.exit().remove()

    # UPDATE old elements present in new data
    #@relations
      #.attr 'id',           (d) -> return 'relation-'+d.id
      #.attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      #.attr 'marker-end',   @getRelationMarkerEnd
      #.attr 'marker-start', @getRelationMarkerStart

    # ENTER new elements present in new data.
    @relations.enter().append('path')
      .attr 'id',           (d) -> return 'relation-'+d.id
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      #.attr 'marker-end',   @getRelationMarkerEnd
      #.attr 'marker-start', @getRelationMarkerStart

    @relations = @relations_cont.selectAll('.relation')

  updateNodesLabels: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes_labels = @nodes_labels_cont.selectAll('.node-label').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes_labels.exit().remove()

    # UPDATE old elements present in new data
    @nodes_labels
      #.attr 'id',    (d,i) -> return 'node-label-'+d.id
      .attr 'class', @getNodeLabelClass
      .text (d) -> return d.name
      .call @formatNodesLabels

    # ENTER new elements present in new data.
    @nodes_labels.enter().append('text')
      .attr 'id',     (d,i) -> return 'node-label-'+d.id
      .attr 'class',  @getNodeLabelClass
      .attr 'dx',     0
      .attr 'dy',     @getNodeLabelYPos
      .text (d) -> return d.name
      .call @formatNodesLabels

    @nodes_labels = @nodes_labels_cont.selectAll('.node-label')

  updateRelationsLabels: (data) ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @relations_labels = @relations_labels_cont.selectAll('.relation-label').data(data)

    # EXIT old elements not present in new data
    @relations_labels.exit().remove()

    # UPDATE old elements present in new data
    @relations_labels.text((d) -> return d.relation_type)
    #@relations_labels.selectAll('textPath').text((d) -> return d.relation_type)

    # ENTER new elements present in new data.
    @relations_labels.enter()
      .append('text')
        .attr  'id', (d) -> return 'relation-label-'+d.id
        .attr  'class', 'relation-label'
        .attr  'x', (d) -> return (d.source.x+d.target.x)*0.5
        .attr  'y', (d) -> return (d.source.y+d.target.y)*0.5
        .attr  'dy', '0.5em'
        .style 'text-anchor', 'middle'
        .text  (d) -> return d.relation_type

      # .append('text')
      #   .attr('id', (d) -> return 'relation-label-'+d.id)
      #   .attr('class', 'relation-label')
      #   .attr('x', 0)
      #   .attr('dy', -4)
      # .append('textPath')
      #   .attr('xlink:href',(d) -> return '#relation-'+d.id) # link textPath to label relation
      #   .style('text-anchor', 'middle')
      #   .attr('startOffset', '50%') 
      #   .text((d) -> return d.relation_type)

    @relations_labels = @relations_labels_cont.selectAll('.relation-label')


  updateForce: (restarForce) ->
    @force.nodes(@data_nodes)
    @force.force('link').links(@data_relations_visibles)
    #@force.restart()

    if restarForce
      @force.alpha(0.5).restart()
    
    # @force
    #   .nodes(@data_nodes)
    #   .links(@data_relations_visibles)
    #   .start()


  # Nodes / Relations methods
  # --------------------------

  updateData: (nodes, relations) ->
    console.log 'canvas current Data', @data_nodes, @data_relations
    # Reset data variables
    # @data_nodes              = []
    # @data_relations          = []
    # @data_relations_visibles = []
    # @linkedByIndex           = {}
    # # Initialize data
    # @initializeData data

    # Setup disable values in nodes
    # @data_nodes.forEach (node) ->
    #   node.disabled = nodes.indexOf(node.id) == -1
    # # Setup disable values in relations
    # @data_relations_visibles.forEach (relation) ->
    #   relation.disabled = relations.indexOf(relation.id) == -1    

  addNodeData: (node) ->
    # check if node is present in @data_nodes
    #console.log 'addNodeData', node.id, node
    if node
      @data_nodes_map.set node.id, node
      @data_nodes.push node

  removeNodeData: (node) ->
    @data_nodes_map.remove node.id
    # We can't use Array.splice because this function could be called inside a loop over nodes & causes drop
    @data_nodes = @data_nodes.filter (d) =>
      return d.id != node.id
  
  addRelationData: (relation) ->
    # We have to add relations to @data.relations which stores all the relations
    index = @data_relations.indexOf relation
    console.log 'addRelationData', index
    # Set source & target as nodes objetcs instead of index number --> !!! We need this???
    relation.source  = @getNodeById relation.source_id
    relation.target  = @getNodeById relation.target_id
    # Add relations to data_relations array if not present yet
    if index == -1
      @data_relations.push relation
    # Add relation to data_relations_visibles array if both nodes exist and are visibles
    if relation.source and relation.target and relation.source.visible and relation.target.visible
      console.log 'addRelationVisible'
      @data_relations_visibles.push relation
      @addRelationToLinkedByIndex relation.source_id, relation.target_id
      #@setLinkIndex()

  # maybe we need to split removeVisibleRelationaData & removeRelationData
  removeRelationData: (relation) =>
    # remove relation from data_relations
    console.log 'remove relation from data_relations', @data_relations
    index = @data_relations.indexOf relation
    console.log 'index', index
    if index != -1
      @data_relations.splice index, 1
    @removeVisibleRelationData relation

  removeVisibleRelationData: (relation) =>
    console.log 'remove relation from data_relations_visibles', @data_relations_visibles
    # remove relation from data_relations_visibles
    index = @data_relations_visibles.indexOf relation
    if index != -1
      @data_relations_visibles.splice index, 1

  addRelationToLinkedByIndex: (source, target) ->
    # count number of relations between 2 nodes
    @linkedByIndex[source+','+target] = ++@linkedByIndex[source+','+target] || 1

  

  updateRelationsLabelsData: ->
    if @node_active
      @updateRelationsLabels @getNodeRelations(@node_active )

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

  addNode: (node) ->
    console.log 'addNode', node
    @addNodeData node
    @render true
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    console.log 'removeNode', node
    # unfocus node to remove
    if @node_active == node.id
      @unfocusNode()
    @removeNodeData node
    @removeNodeRelations node
    @render true

  removeNodeRelations: (node) =>
    # update data_relations_visibles removing relations with removed node
    @data_relations_visibles = @data_relations_visibles.filter (d) =>
      return d.source_id != node.id and d.target_id != node.id

  addRelation: (relation) ->
    console.log 'addRelation', relation
    @addRelationData relation
    # update nodes relations size if needed to take into acount the added relation
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()
    @render true

  removeRelation: (relation) ->
    console.log 'removeRelation', relation
    @removeRelationData relation
    @updateRelationsLabelsData()
    # update nodes relations size if needed to take into acount the removed relation
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()
    @render true

  showNode: (node) ->
    console.log 'show node', node
    # add node to data_nodes array
    @addNodeData node
    # check node relations (in data.relations)
    @data_relations.forEach (relation) =>
      # if node is present in some relation we add it to data_relations and/or data_relations_visibles array
      if relation.source_id  == node.id or relation.target_id == node.id
        @addRelationData relation   
    @render true

  hideNode: (node) ->
    @removeNode node

  focusNode: (node) ->
    @node_active = node.id
    console.log 'focus node', @node_active
    @container.selectAll('.node.active').classed('active', false)
    @container.selectAll('#node-'+node.id).classed('active', true)
    @updateRelationsLabelsData()

  unfocusNode: ->
    @node_active = null
    console.log 'unfocus node', @node_active
    @container.selectAll('.node.active').classed('active', false)
    @onNodeOut()


  # Resize Methods
  # ---------------

  resize: ->
    console.log 'VisualizationGraphCanvas resize'
    # Update Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.origin.x  = (@viewport.width*0.5) - @viewport.center.x
    @viewport.origin.y  = (@viewport.height*0.5) - @viewport.center.y

    # Update canvas
    @svg.attr   'width', @viewport.width
    @svg.attr   'height', @viewport.height
    @rescale()
    # Update force size
    #@force.size [@viewport.width, @viewport.height]

  rescale: ->
    @container.attr       'transform', @getContainerTransform()
    translateStr = 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'
    @relations_cont.attr        'transform', translateStr
    @relations_labels_cont.attr 'transform', translateStr
    @nodes_cont.attr            'transform', translateStr
    @nodes_labels_cont.attr     'transform', translateStr

  setOffsetX: (offset) ->
    @viewport.offsetx = if offset < 0 then 0 else offset
    @container.transition()
      .duration(400)
      .ease('ease-out')
      .attr('transform', @getContainerTransform())

  setOffsetY: (offset) ->
    @viewport.offsety = if offset < 0 then 0 else offset
    if @container
      @container.attr 'transform', @getContainerTransform()

   getContainerTransform: ->
    return 'translate(' + (@viewport.center.x+@viewport.origin.x+@viewport.x-@viewport.offsetx) + ',' + (@viewport.center.y+@viewport.origin.y+@viewport.y-@viewport.offsety) + ')scale(' + @viewport.scale + ')'


  # Config Methods
  # ---------------

  # updateNodesColor: (value) =>
  #   @parameters.nodesColor = value
  #   @nodes
  #     .style('fill', @getNodeFill)
  #     .style('stroke', @getNodeColor)

  # updateNodesSize: (value) =>
  #   console.log 'updateNodesSize', value
  #   @parameters.nodesSize = parseInt(value)
  #   # if nodesSize = 1, set nodes size based on its number of relations
  #   if @parameters.nodesSize == 1
  #     @setNodesRelationsSize()
  #   # update nodes radius
  #   @nodes.attr('r', @getNodeSize)
  #   # update nodes labels position
  #   @nodes_labels.selectAll('.first-line').attr('dy', @getNodeLabelYPos)
  #   # update relations arrows position
  #   @relations.attr 'd', @drawRelationPath

  # toogleNodesLabel: (value) =>
  #   @nodes_labels.classed 'hide', !value

  # toogleNodesImage: (value) =>
  #   @parameters.showNodesImage = value
  #   console.log 'toogleNodesImage',  @parameters
  #   @updateNodes()
  
  # toogleNodesWithoutRelation: (value) =>
  #   if value
  #     @data_nodes.forEach (d) =>
  #       if !@hasNodeRelations(d)
  #         @removeNode d
  #   else
  #     # TODO!!! Check visibility before add a node
  #     @data_nodes.forEach (d) =>
  #       if !@hasNodeRelations(d)
  #         @addNode d
  #   @render()

  # updateRelationsCurvature: (value) ->
  #   @parameters.relationsCurvature = value
  #   @onTick()

  # updateRelationsLineStyle: (value) ->
  #   @relations_cont.attr 'class', 'relations-cont '+@getRelationsLineStyle(value)

  getRelationsLineStyle: (value) ->
    lineStyle = switch
      when value == 0 then 'line-solid'
      when value == 1 then 'line-dashed'
      else 'line-dotted' 
    return lineStyle

  # updateForceLayoutParameter: (param, value) ->
  #   @force.stop()
  #   if param == 'linkDistance'
  #     @force.linkDistance value
  #   else if param == 'linkStrength'
  #     @force.linkStrength value
  #   else if param == 'friction'
  #     @force.friction value
  #   else if param == 'charge'
  #     @force.charge value
  #   else if param == 'theta'
  #     @force.theta value
  #   else if param == 'gravity'
  #     @force.gravity value
  #   @force.start()


  # Navigation Methods
  # ---------------

  zoomIn: ->
    @zoom @viewport.scale*1.2
    
  zoomOut: ->
    @zoom @viewport.scale/1.2
  
  zoom: (value) ->
    @viewport.scale = value
    @container
      .transition()
        .duration(500)
        .attr 'transform', @getContainerTransform()


  # Events Methods
  # ---------------

  # Canvas Drag Events
  onCanvasDragStart: =>
    @svg.style('cursor','move')

  onCanvasDragged: =>
    @viewport.x  += d3.event.dx
    @viewport.y  += d3.event.dy
    @viewport.dx += d3.event.dx
    @viewport.dy += d3.event.dy
    @rescale()
    d3.event.sourceEvent.stopPropagation()  # silence other listeners

  onCanvasDragEnd: =>
    @svg.style('cursor','default')
    # Skip if viewport has no translation
    if @viewport.dx == 0 and @viewport.dy == 0
      Backbone.trigger 'visualization.node.hideInfo'
      return
    # TODO! Add viewportMove action to history
    @viewport.dx = @viewport.dy = 0;
   
  # Nodes drag events
  onNodeDragStart: (d) =>
    # d3.event.sourceEvent.stopPropagation() # silence other listeners
    # @viewport.drag.x = d.x
    # @viewport.drag.y = d.y
    if !d3.event.active
      @force.alphaTarget(0.1).restart()
  
  onNodeDragged: (d) =>
    @force.fix d, d3.event.x, d3.event.y

  onNodeDragEnd: (d) =>
    # d3.event.sourceEvent.stopPropagation() # silence other listeners
    # if @viewport.drag.x == d.x and @viewport.drag.y == d.y
    #   return  # Skip if has no translation
    # # fix the node position when the node is dragged
    # d.fixed = true;
    if !d3.event.active
      @force.alphaTarget(0)

  onNodeOver: (d) =>
    # skip if any node is active
    if @node_active
      return

    # add relations labels  
    @updateRelationsLabels @getNodeRelations(d.id)

    #@nodes.select('circle')
    #  .style('fill', (o) => return if @areNodesRelated(d, o) then @color(o.node_type) else @mixColor(@color(o.node_type), '#ffffff') )
    #
    # highlight related nodes labels
    @nodes_labels.classed 'weaken', true
    @nodes_labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)
    # highlight node relations
    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source_id == d.id || o.target_id == d.id

  onNodeOut: (d) =>
    console.log 'nodeout', @node_active
    # skip if any node is active
    if @node_active
      return

    # clear relations labels
    @updateRelationsLabels {}

    #@nodes.select('circle')
    #  .style('fill', (o) => return @color(o.node_type))
    #
    @nodes_labels.classed 'weaken', false
    @nodes_labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false

  onNodeClick: (d) =>
    # Avoid trigger click on dragEnd
    if d3.event.defaultPrevented 
      return
    Backbone.trigger 'visualization.node.showInfo', {node: d}

  onNodeDoubleClick: (d) =>
    # unfix the node position when the node is double clicked
    @force.unfix d
    #d.fixed = false

  # Tick Function
  onTick: =>
    console.log 'on tick'
    # Set relations path & arrow markers
    @relations
      .attr 'd', @drawRelationPath
      #.attr('marker-end', @getRelationMarkerEnd)
      #.attr('marker-start', @getRelationMarkerStart)
    # Set nodes & labels position
    @nodes
      .attr 'cx', (d) -> return d.x
      .attr 'cy', (d) -> return d.y
    # Set nodes labels position
    @nodes_labels
      .attr 'transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')'
    # Set relation labels position
    if @relations_labels
      @relations_labels
        .attr 'x', (d) -> return (d.source.x+d.target.x)*0.5
        .attr 'y', (d) -> return (d.source.y+d.target.y)*0.5
  
  drawRelationPath: (d) =>
    return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y


  # Auxiliar Methods
  # ----------------

  getNodeById: (id) ->
    return @data_nodes_map.get id

  getNodeRelations: (id) ->
    return @data_relations_visibles.filter (d) => return d.source_id == id || d.target_id == id

  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) ->
      return d.source_id == node.id || d.target_id == node.id

  areNodesRelated: (a, b) ->
    return @linkedByIndex[a.id + ',' + b.id] || @linkedByIndex[b.id + ',' + a.id] || a.id == b.id

  getNodeLabelClass: (d) =>
    str = 'node-label'
    if !@parameters.showNodesLabel
      str += ' hide'
    if d.disabled
      str += ' disabled'
    return str

  getNodeLabelYPos: (d) =>
    return parseInt(@svg.select('#node-'+d.id).attr('r'))+13

  getNodeColor: (d) =>
    if @parameters.nodesColor == 'qualitative'
       color = @colorQualitativeScale d.node_type  
     else if @parameters.nodesColor == 'quantitative'
       color = @colorQuantitativeScale d.node_type
     else
       color = @COLORS[@parameters.nodesColor]
    return color

  getNodeFill: (d) =>
    if d.disabled
      fill = '#d3d7db'
    else if @parameters.showNodesImage and d.image != null
      fill = 'url(#node-pattern-'+d.id+')'
    else
      fill = @getNodeColor(d)
    return fill

  getNodeSize: (d) =>
    # if nodesSize = 1, set size based on node relations
    if @parameters.nodesSize == 1
      size = if @nodes_relations_size[d.id] then 5+15*(@nodes_relations_size[d.id]/@nodes_relations_size.max) else 5
    else
      size = @parameters.nodesSize
    return size

  getRelationMarkerEnd: (d) -> 
    return if d.direction and d.angle >= 0 then 'url(#arrow-end)' else ''
  
  getRelationMarkerStart: (d) -> 
    return if d.direction and d.angle < 0 then 'url(#arrow-start)' else ''

  setNodesRelationsSize: =>
    @nodes_relations_size = {}
    # initialize nodes_relations_size object with all nodes with zero value
    @data_nodes.forEach (d) =>
      @nodes_relations_size[d.id] = 0
    # increment each node value which has a relation
    @data_relations_visibles.forEach (d) =>
      @nodes_relations_size[d.source_id] += 1
      @nodes_relations_size[d.target_id] += 1
    @nodes_relations_size.max = d3.max d3.entries(@nodes_relations_size), (d) -> return d.value
    #console.log 'setNodesRelationsSize', @nodes_relations_size, @data_nodes

  formatNodesLabels: (nodes) ->
    nodes.each () ->
      #console.log 'formatNodesLabels 2', @parameters.nodesSize
      node = d3.select(this)
      words = node.text().split(/\s+/).reverse()
      line = []
      i = 0
      dy = parseFloat node.attr('dy')
      tspan = node.text(null).append('tspan')
        .attr('class', 'first-line')
        .attr('x', 0)
        .attr('dx', 5)
        .attr('dy', dy)
      while word = words.pop()
        line.push word
        tspan.text line.join(' ')
        if tspan.node().getComputedTextLength() > 120
          line.pop()
          tspan.text line.join(' ')
          line = [word]
          # if firs tspan, we add ellipsis
          if i == 0
            node.append('tspan')
              .attr('class', 'ellipsis')
              .attr('dx', 2)
              .text('...')
          tspan = node.append('tspan')
            .attr('x', 0)
            .attr('dy', 13)
            .text(word)
          i++
      # reset dx if label is not multiline
      if i == 0
        tspan.attr('dx', 0)


module.exports = VisualizationGraphCanvasTest