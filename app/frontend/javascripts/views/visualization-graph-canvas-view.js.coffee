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

    @updateLayout()

  updateLayout: ->

    console.log 'updateLayout'

    @updateRelations()
    @updateNodes()
    @updateLabels()
    @updateForce()

  updateNodes: ->
    @nodes = @nodes.data(@data_current_nodes)
    @nodes.enter().append('g')
      #.attr('id', (d) -> return 'node-'+d.id)
      .attr('class', 'node')
      .call(@forceDrag)
      .on('mouseover',  @onNodeOver)
      .on('mouseout',   @onNodeOut)
      .on('click',      @onNodeClick)
      .on('dblclick',   @onNodeDoubleClick)
    .append('circle')
      .attr('class', 'node-circle')
      .attr('r', @NODES_SIZE)
      .style('fill', (d) => return @color(d.node_type))
    @nodes.exit().remove()

  updateRelations: ->
    @relations = @relations.data(@data_current_relations)
    @relations.enter().append('line')
      #.attr('id', (d) -> return 'relation-'+d.id)
      .attr('class', 'relation')
    @relations.exit().remove()

  updateLabels: ->
    @labels = @labels.data(@data_current_nodes)
    @labels.enter().append('text')
      #.attr('id', (d,i) -> return 'label-'+d.id)
      .attr('class', 'label')
      .attr('dx', @NODES_SIZE+6)
      .attr('dy', '.35em')
    @labels.text((d) -> return d.name)  # Enter+Update text label
    @labels.exit().remove()

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
    # We can't use Array.splice because this function could be called inside a loop over nodes & causes drop
    @data_current_nodes = @data_current_nodes.filter (d) =>
      return d.id != node.id
  
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

  updateNodeName: (node, value) ->
    index = @data_nodes.indexOf node
    if index >= 0
      @data_nodes[index].name = value
    @updateLabels()

  updateNodeDescription: (node, value) ->
    index = @data_nodes.indexOf node
    if index >= 0
      @data_nodes[index].description = value


  # Resize Methods
  # ---------------

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


  # Config Methods
  # ---------------

  toogleLabels: (value) =>
    @labels.classed 'hide', value
  
  toogleNodesWithoutRelation: (value) =>
    if value
      @data_current_nodes.forEach (d) =>
        if !@hasNodeRelations(d)
          @removeNode d
    else
      # TODO!!! Check visibility before add a node
      @data_nodes.forEach (d) =>
        if !@hasNodeRelations(d)
          @addNode d
    @updateLayout()

  updateForceLayoutParameter: (param, value) ->
    @force.stop()
    if param == 'linkDistance'
      @force.linkDistance value
    else if param == 'linkStrength'
      @force.linkStrength value
    else if param == 'friction'
      @force.friction value
    else if param == 'charge'
      @force.charge value
    else if param == 'theta'
      @force.theta value
    else if param == 'gravity'
      @force.gravity value
    @force.start()


  # Navigation Methods
  # ---------------

  zoomIn: ->
    console.log 'zoomin'
    
  zoomOut: ->
    console.log 'zoomout'

  toogleFullscreen: ->
    console.log 'fullscreen'


  # Events Methods
  # ---------------

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
    @nodes.classed 'weaken', true
    @nodes.classed 'highlighted', (o) => return @areNodesRelated(d, o)

    @labels.classed 'weaken', true
    @labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)

    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index

  onNodeOut: (d) =>
    @nodes.classed 'weaken', false
    @nodes.classed 'highlighted', false
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

  
  # Auxiliar Methods
  # ----------------

  areNodesRelated: (a, b) ->
    return @linkedByIndex[a.id + ',' + b.id] || @linkedByIndex[b.id + ',' + a.id] || a.id == b.id
  
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