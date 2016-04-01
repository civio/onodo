d3 = require 'd3'

class VisualizationGraphCanvas extends Backbone.View

  NODES_SIZE: 11

  COLOR_CUALITATIVE: [
    '#ef9387', '#fccf80', '#fee378', '#d9d070', '#82a389', '#87948f', 
    '#89b5df', '#aebedf', '#c6a1bc', '#f1b6ae', '#a8a6a0', '#e0deda'
  ]

  svg:              null
  container:        null
  color:            null
  data:             null
  data_nodes:       []
  data_nodes_map:   d3.map()
  data_relations:   []
  data_relations_visibles:[]
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

    # Setup color scale
    #@color = d3.scale.category20()
    @color            = d3.scale.ordinal().range( @COLOR_CUALITATIVE )
    @colorInterpolate = d3.scale.linear()
                          .domain([0,100])
                          .interpolate(d3.interpolateRgb)

    # Setup Data
    @initializeData( options.data )

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x = @viewport.width*0.5
    @viewport.center.y = @viewport.height*0.5

    # Setup force
    @force = d3.layout.force()
      .charge(-150)
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
    @render()

  initializeData: (data) ->

    console.log 'initializeData'

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d

    # Setup color ordinal scale domain
    @color.domain data.nodes.map( (d) -> d.node_type )

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
        @linkedByIndex[d.source_id+','+d.target_id] = true

    console.log 'current nodes', @data_nodes
    console.log 'current relations', @data_relations_visibles

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
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    # Join new data with old elements, if any
    @nodes = @nodes_cont.selectAll('.node').data(@data_nodes)

    # ENTER
    # Create new elements as needed.
    @nodes.enter().append('g')
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
      .style('stroke', (d) => return @color(d.node_type))

    # ENTER + UPDATE
    # Appending to the enter selection expands the update selection to include
    # entering elements; so, operations on the update selection after appending to
    # the enter selection will apply to both entering and updating nodes.
    @nodes.attr('id', (d) -> return 'node-'+d.id)

    # EXIT
    # Remove old elements as needed.
    @nodes.exit().remove()

  updateRelations: ->
    @relations = @relations.data(@data_relations_visibles)
    #@relations.enter().append('line')
    @relations.enter().append('path')
      .attr('id', (d) -> return 'relation-'+d.id)
      .attr('class', 'relation')
    @relations.exit().remove()

  updateLabels: ->
    @labels = @labels.data(@data_nodes)
    @labels.enter().append('text')
      .attr('id', (d,i) -> return 'label-'+d.id)
      .attr('class', 'label')
      .attr('dx', 0)
      .attr('dy', @NODES_SIZE+15)
    @labels.text((d) -> return d.name)  # Enter+Update text label
    @labels.exit().remove()

  updateForce: ->
    @force
      .nodes(@data_nodes)
      .links(@data_relations_visibles)
      .start()


  # Nodes / Relations methods
  # --------------------------

  addNodeData: (node) ->
    console.log 'addNodeData'
    #console.log @data_nodes
    @data_nodes_map.set node.id, node
    @data_nodes.push node
    #console.log @data_nodes

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
      @linkedByIndex[relation.source_id+','+relation.target_id] = true

  # maybe we need to split removeVisibleRelationaData & removeRelationData
  removeRelationData: (relation) ->
    # remove relation from data_relations
    index = @data_relations.indexOf relation
    if index != -1
      @data_relations.splice index, 1
    # remove relation from data_relations_visibles
    index = @data_relations_visible.indexOf relation
    if index != -1
      @data_relations_visible.splice index, 1

  addNode: (node) ->
    console.log 'addNode', node
    @addNodeData node
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    @removeNodeData node
    @removeNodeRelations node

  removeNodeRelations: (node) =>
    # update data_relations_visibles removing relations with removed node
    @data_relations_visibles = @data_relations_visibles.filter (d) =>
      return d.source_id != node.id and d.target_id != node.id

  addRelation: (relation) ->
    @addRelationData relation

  removeRelation: (relation) ->
    @removeRelationData relation

  showNode: (node) ->
    console.log 'show node', node
    # add node to data_nodes array
    @addNodeData node
    # check node relations (in data.relations)
    @data_relations.forEach (relation) =>
      # if node is present in some relation we add it to data_relations and/or data_relations_visibles array
      if relation.source_id  == node.id or relation.target_id == node.id
        @addRelationData relation   

  hideNode: (node) ->
    @removeNode node

  focusNode: (node)->
    console.log node
    @unfocusNode()
    @nodes.selectAll('#node-'+node.id+' .node-circle').classed('active', true)

  unfocusNode: ->
    @nodes.selectAll('.node-circle.active').classed('active', false)

  updateNodeName: (node, value) ->
    console.log 'updateNodeName', node, value
    data_node = @getNodeById node.id
    if data_node
      data_node.name = value
      @updateLabels()

  updateNodeDescription: (node, value) ->
    console.log 'updateNodeDescription', node, value
    data_node = @getNodeById node.id
    if data_node
      data_node.description = value


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
    @container.attr       'transform', 'translate(' + (@viewport.center.x+@viewport.origin.x+@viewport.x) + ',' + (@viewport.center.y+@viewport.origin.y+@viewport.y) + ')scale(' + @viewport.scale + ')'
    @relations_cont.attr  'transform', 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'
    @nodes_cont.attr      'transform', 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'
    @labels_cont.attr     'transform', 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'


  # Config Methods
  # ---------------

  toogleLabels: (value) =>
    @labels.classed 'hide', value
  
  toogleNodesWithoutRelation: (value) =>
    if value
      @data_nodes.forEach (d) =>
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
    @viewport.scale *= 1.2
    @rescale()
    
  zoomOut: ->
    @viewport.scale /= 1.2
    @rescale()


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
      Backbone.trigger 'visualization.node.hideInfo'
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
    d3.event.sourceEvent.stopPropagation() # silence other listeners
    if @viewport.drag.x == d.x and @viewport.drag.y == d.y
      return  # Skip if has no translation
    # fix the node position when the node is dragged
    d.fixed = true;

  onNodeOver: (d) =>
    @nodes.select('circle')
      .style('fill', (o) => return if @areNodesRelated(d, o) then @color(o.node_type) else @mixColor(@color(o.node_type), '#ffffff') )

    @labels.classed 'weaken', true
    @labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)

    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index

  onNodeOut: (d) =>
    @nodes.select('circle')
      .style('fill', (o) => return @color(o.node_type))
    @labels.classed 'weaken', false
    @labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false

  onNodeClick: (d) =>
    # Avoid trigger click on dragEnd
    if d3.event.defaultPrevented 
      return
    Backbone.trigger 'visualization.node.showInfo', {node: d}

  onNodeDoubleClick: (d) =>
    # unfix the node position when the node is double clicked
    d.fixed = false

  # Tick Function
  onTick: =>
    # Set relations path
    @relations.attr 'd', (d) ->
      dx = d.target.x - d.source.x
      dy = d.target.y - d.source.y
      dr = Math.sqrt dx*dx + dy*dy
      return 'M' + d.source.x + ',' + d.source.y + 'A' + dr + ',' + dr + ' 0 0,1 ' + d.target.x + ',' + d.target.y
    # Set nodes & labels position
    @nodes.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
    @labels.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')  

  
  # Auxiliar Methods
  # ----------------

  getNodeById: (id) ->
    return @data_nodes_map.get id
  
  getNodeRelations: (node) ->
    arr = []
    @data_relations_visibles.forEach (d) ->
      if d.source_id == node.id || d.target_id == node.id
        arr.push d
    return arr

  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) ->
      return d.source_id == node.id || d.target_id == node.id

  areNodesRelated: (a, b) ->
    return @linkedByIndex[a.id + ',' + b.id] || @linkedByIndex[b.id + ',' + a.id] || a.id == b.id

  # mix color auxiliar function:
  # c1 & c2 must be strings as '#XXXXXX'
  # weight must be an integer between 0 & 100
  mixColor: (c1, c2, weight) ->
    # convert a decimal value to hex
    d2h = (d) -> return d.toString(16)
    # convert a hex value to decimal 
    h2d = (h) -> return parseInt(h, 16)
    # set the weight to 50%, if that argument is omitted
    weight = if typeof(weight) != 'undefined' then weight else 50 
    color = "#"
    # loop through each of the 3 hex pairs—red, green, and blue
    for i in [1..6] by 2
      # extract the current pairs
      v1 = h2d(c1.substr(i, 2))
      v2 = h2d(c2.substr(i, 2))
      # combine the current pairs from each source color, according to the specified weight
      val = d2h(Math.floor(v2 + (v1 - v2) * (weight / 100.0)))
      # prepend a '0' if val results in a single digit
      while val.length < 2
        val = '0' + val
      # concatenate val to our new color string
      color += val
    return color


module.exports = VisualizationGraphCanvas