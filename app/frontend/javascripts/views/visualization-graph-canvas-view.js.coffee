d3 = require 'd3'

class VisualizationGraphCanvasView extends Backbone.View

  NODES_SIZE: 8

  svg:              null
  container:        null
  color:            null
  data:             null
  data_nodes:       []
  data_nodes_map:   d3.map()
  data_relations:   []
  data_current_nodes:     []
  data_current_relations: []
  nodes_cont:       null
  relations_cont:   null
  labels_cont:      null
  nodes:            null
  nodes_symbol:     null
  relations:        null
  labels:           null
  force:            null
  forceDrag:        null
  linkedByIndex:    {}
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
    drag:
      x: 0
      y: 0
    scale: 1

  initialize: (options) ->

    console.log 'initialize canvas'

    # Setup Data
    @data = options.data
    @initializaData()

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x  = @viewport.width*0.5
    @viewport.center.y  = @viewport.height*0.5

    # Setup color scale
    @color = d3.scale.category20()

    # Setup force
    @force = d3.layout.force()
      .charge(-120)
      .linkDistance(90)
      #.linkStrength(2)
      .size([@viewport.width, @viewport.height])
      .on('tick', @onTick)

    @forceDrag = @force.drag()
      .on('dragstart',  @onNodeDragStart)
      .on('dragend',    @onNodeDragEnd)

    # Setup SVG
    @svg = d3.select( @$el.get(0) )
      .append('svg:svg')
        .attr('width',  @viewport.width)
        .attr('height', @viewport.height)
        .call(d3.behavior.drag()
          .on('drag',       @onCanvasDrag)
          .on('dragstart',  @onCanvasDragStart)
          .on('dragend',    @onCanvasDragEnd))

    # Setup containers
    @container      = @svg.append('g')
    @relations_cont = @container.append('g').attr('class', 'relations-cont')
    @nodes_cont     = @container.append('g').attr('class', 'nodes-cont')
    @labels_cont    = @container.append('g').attr('class', 'labels-cont')

    @rescale()  # Translate svg

  initializaData: ->

    # Setup Nodes
    @data.nodes.forEach (d) =>
      @data_nodes_map.set d.id, d
      @data_nodes.push d
      # Add to data_current_nodes if visible
      if d.visible
        @data_current_nodes.push d

    # Setup Relations: change relations source & target N based id to 0 based ids & setup linkedByIndex object
    @data.relations.forEach (d) =>
      # Set source & target as nodes objetcs instead of index number
      d.source = @data_nodes_map.get d.source_id
      d.target = @data_nodes_map.get d.target_id
      @data_relations.push d
      # Add to data_current_relations if both nodes are visibles
      if d.source.visible and d.target.visible
        @data_current_relations.push d
      @linkedByIndex[d.source_id+','+d.target_id] = true

    console.log 'current nodes', @data_current_nodes
    console.log 'current relations', @data_current_relations

  render: ->

    console.log 'render canvas'

    @nodes      = @nodes_cont.selectAll('.node')
    @relations  = @relations_cont.selectAll('.relation')
    @labels     = @labels_cont.selectAll('.text')

    @setupEvents()
    @updateLayout()

  updateLayout: ->

    console.log 'updateLayout'

    # Setup Links
    @relations = @relations.data(@data_current_relations)
    @relations.enter().append('line')
      #.attr('id', (d) -> return 'relation-'+d.id)
      .attr('class', 'relation')
    @relations.exit().remove()

    # Setup Nodes
    @nodes = @nodes.data(@data_current_nodes)
    @nodes.enter().append('g')
      #.attr('id', (d) -> return 'node-'+d.id)
      .attr('class', 'node')
      .call(@forceDrag)
      .on('mouseover',  @onNodeOver)
      .on('mouseout',   @onNodeOut)
      .on('click',      @onNodeClick)
      .on('dblclick',   @onNodeDoubleClick)
    @nodes.exit().remove()

    # Setup Nodes Symbol
    @nodes_symbol = @nodes.append('circle')
      .attr('class', 'node-symbol')
      .attr('r', @NODES_SIZE)
      .style('fill', (d) => return @color(d.node_type))

    # Setup Nodes Text
    @labels = @labels.data(@data_current_nodes)
    @labels.enter().append('text')
      #.attr('id', (d,i) -> return 'label-'+d.id)
      .attr('class', 'label')
      .attr('dx', @NODES_SIZE+6)
      .attr('dy', '.35em')
    @labels.text((d) -> return d.name)  # Enter+Update text label
    @labels.exit().remove()

    @updateForce()
    
  updateForce: ->
    @force
      .nodes(@data_current_nodes)
      .links(@data_current_relations)
      .start()


  # Nodes / Relations methods
  # --------------------------

  addNodeData: (node) ->
    @data_current_nodes.push node

  removeNodeData: (node) ->
    index = @data_current_nodes.indexOf node
    if index >= 0
      @data_current_nodes.splice index, 1
  
  addRelationData: (relation) ->
    @data_current_relations.push relation

  removeRelationData: (relation) ->
    index = @data_current_relations.indexOf relation
    if index >= 0
      @data_current_relations.splice index, 1

  addNode: (node) ->
    @addNodeData node

  removeNode: (node) ->
    @removeNodeData node
    @removeNodeRelations node

  removeNodeRelations: (node) =>
    # update data_current_relations removing relations with removed node
    @data_current_relations = @data_current_relations.filter (d) =>
      return d.source.id != node.id and d.target.id != node.id

  addRelation: (relation) ->
    @addRelationData relation

  removeRelation: (relation) ->
    @removeRelationData relation

  showNode: (node) ->
    # add node to data_current_nodes array
    @addNodeData node
    # check node relations (in data_relations)
    @data_relations.forEach (relation) =>
      if (relation.source.id == node.id and relation.target.visible) or (relation.target.id == node.id and relation.source.visible)
        @addRelationData relation   # add relation to data_current_relations array

  hideNode: (node) ->
    @removeNode node


  # Events Methods
  # ---------------

  setupEvents: ->
    # Subscribe Config Panel Events
    Backbone.on 'config.toogle.labels', @onToogleLabels, @
    Backbone.on 'config.toogle.norelations', @onToogleNodesWithoutRelation, @
    Backbone.on 'config.param.change', @onUpdateForceParameters, @
    # Subscribe Navigation Events
    Backbone.on 'navigation.zoomin', @onZoomIn, @
    Backbone.on 'navigation.zoomout', @onZoomOut, @
    Backbone.on 'navigation.fullscreen', @onFullscreen, @

  onToogleLabels: (e) =>
    @labels.classed 'hide', e.value

  # TODO!!! Revisar!
  onToogleNodesWithoutRelation: (e) =>
    console.log @data_current_nodes.length
    @data_current_nodes.forEach (d) =>
      if !@hasNodeRelations(d)
        @removeNode d
    console.log @data_current_nodes.length
    @updateLayout()

  onUpdateForceParameters: (e) ->
    @force.stop()
    if e.name == 'linkDistance'
      @force.linkDistance e.value
    else if e.name == 'linkStrength'
      @force.linkStrength e.value
    else if e.name == 'friction'
      @force.friction e.value
    else if e.name == 'charge'
      @force.charge e.value
    else if e.name == 'theta'
      @force.theta e.value
    else if e.name == 'gravity'
      @force.gravity e.value
    @force.start()

  onZoomIn: ->
    console.log 'zoomin'
    
  onZoomOut: ->
    console.log 'zoomout'

  onFullscreen: ->
    console.log 'fullscreen'

  # Canvas Drag Events
  onCanvasDrag: =>
    @viewport.x  += d3.event.dx
    @viewport.y  += d3.event.dy
    @viewport.dx += d3.event.dx
    @viewport.dy += d3.event.dy
    @rescale()
    d3.event.sourceEvent.stopPropagation()  # silence other listeners

  onCanvasDragStart: =>
    @svg.style('cursor','move')

  onCanvasDragEnd: =>
    # Skip if viewport has no translation
    if @viewport.dx == 0 and @viewport.dy == 0
      return
    # TODO! Add viewportMove action to history
    @viewport.dx = @viewport.dy = 0;
    @svg.style('cursor','default')

  # Nodes drag events
  onNodeDragStart: (d) =>
    d3.event.sourceEvent.stopPropagation() # silence other listeners
    @viewport.drag.x = d.x
    @viewport.drag.y = d.y
  
  onNodeDragEnd: (d) =>
    if @viewport.drag.x == d.x and @viewport.drag.y == d.y
      return  # Skip if has no translation
    # fix the node position when the node is dragged
    d.fixed = true;

  onNodeOver: (d) =>
    @nodes_symbol.classed 'weaken', true
    @nodes_symbol.classed 'highlighted', (o) => return @hasNodesRelation(d, o)

    @labels.classed 'weaken', true
    @labels.classed 'highlighted', (o) => return @hasNodesRelation(d, o)

    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index

  onNodeOut: (d) =>
    @nodes_symbol.classed 'weaken', false
    @nodes_symbol.classed 'highlighted', false
    @labels.classed 'weaken', false
    @labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false

  onNodeClick: (d) =>

  onNodeDoubleClick: (d) =>
    # unfix the node position when the node is double clicked
    d.fixed = false

  # Tick Function
  onTick: =>
    @relations.attr('x1', (d) -> return d.source.x)
        .attr('y1', (d) -> return d.source.y)
        .attr('x2', (d) -> return d.target.x)
        .attr('y2', (d) -> return d.target.y)
    @nodes.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
    @labels.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')  

  resize: ->
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
    @force.size [@viewport.width, @viewport.height]

  rescale: ->
    @container.attr 'transform', 'translate(' + (@viewport.origin.x+@viewport.x) + ',' + (@viewport.origin.y+@viewport.y) + ')scale(' + @viewport.scale + ')'

  # Utils Functions
  hasNodesRelation: (a, b) ->
    return @linkedByIndex[a.index + ',' + b.index] || @linkedByIndex[b.index + ',' + a.index] || a.index == b.index

  hasNodeRelations: (node) ->
    return @data_current_relations.some (d) ->
      return d.source.id == node.id || d.target.id == node.id

  getNodeRelations: (node) ->
    arr = []
    @data_current_relations.forEach (d) ->
      if d.source.id == node.id || d.target.id == node.id
        arr.push d
    return arr

module.exports = VisualizationGraphCanvasView