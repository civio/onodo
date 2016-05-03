d3 = require 'd3'

class VisualizationGraphCanvas extends Backbone.View

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
      @COLORS['solid-1']
      @COLORS['solid-2']
      @COLORS['solid-3']
      @COLORS['solid-4']
      @COLORS['solid-5']
      @COLORS['solid-6']
      @COLORS['solid-7']
      @COLORS['solid-8']
      @COLORS['solid-9']
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

    @parameters = options.parameters

    console.log 'initialize canvas', @parameters

    # Setup color scale
    @colorQualitativeScale  = d3.scale.ordinal().range( @COLOR_QUALITATIVE )
    @colorQuantitativeScale = d3.scale.ordinal().range( @COLOR_QUANTITATIVE )

    # Setup Data
    @initializeData( options.data )

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x = @viewport.width*0.5
    @viewport.center.y = @viewport.height*0.5

    # Setup force
    @force = d3.layout.force()
      .linkDistance(@parameters.linkDistance)
      .linkStrength(@parameters.linkStrength)
      .friction(@parameters.friction)
      .charge(@parameters.charge)
      .theta(@parameters.theta)
      .gravity(@parameters.gravity)
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

    # Define Arrow Markers
    defs = @svg.append('svg:defs')
    # Setup arrow end
    defs.append('svg:marker')
        .attr('id', 'arrow-end')
        .attr('class', 'arrow-marker')
        .attr('viewBox', '-8 -10 8 20')
        .attr('refX', 2)
        .attr("refY", 0)
        .attr('markerWidth', 10)
        .attr('markerHeight', 10)
        .attr('orient', 'auto')
      .append('svg:path')
        .attr('d', 'M -10 -8 L 0 0 L -10 8')
    # Setup arrow start
    defs.append('svg:marker')
        .attr('id', 'arrow-start')
        .attr('class', 'arrow-marker')
        .attr('viewBox', '0 -10 8 20')
        .attr('refX', -2)
        .attr('refY', 0)
        .attr('markerWidth', 10)
        .attr('markerHeight', 10)
        .attr('orient', 'auto')
      .append('svg:path')
        .attr('d', 'M 10 -8 L 0 0 L 10 8')

    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()  # initialize nodes_relations_size array

    # Setup containers
    @container            = @svg.append('g')
    @relations_cont       = @container.append('g').attr('class', 'relations-cont '+@getRelationsLineStyle(@parameters.relationsLineStyle))
    @nodes_cont           = @container.append('g').attr('class', 'nodes-cont')
    @relations_labels_cont= @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_labels_cont    = @container.append('g').attr('class', 'nodes-labels-cont')
    
    @rescale()  # Translate svg
    @updateLayout()

  initializeData: (data) ->

    console.log 'initializeData'

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d

    # Setup color ordinal scale domain
    @colorQualitativeScale.domain data.nodes.map( (d) -> d.node_type )
    @colorQuantitativeScale.domain data.nodes.map( (d) -> d.node_type )

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

  updateLayout: ->
    console.log 'updateLayout'
    @updateRelations()
    @updateRelationsLabels()
    @updateNodes()
    @updateNodesLabels()
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
      .attr('r', @getNodeSize)

    # ENTER + UPDATE
    # Appending to the enter selection expands the update selection to include
    # entering elements; so, operations on the update selection after appending to
    # the enter selection will apply to both entering and updating nodes.
    @nodes.attr('id', (d) -> return 'node-'+d.id)
    # set nodes color based on parameters.nodesColor value
    @nodes.selectAll('.node-circle')
      .style('fill', @setNodesColor)
      .style('stroke', @setNodesColor)

    # EXIT
    # Remove old elements as needed.
    @nodes.exit().remove()

  updateRelations: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    # Join new data with old elements, if any
    @relations = @relations_cont.selectAll('.relation').data(@data_relations_visibles)

    # ENTER
    # Create new elements as needed.
    @relations.enter().append('path')
      .attr('class', 'relation')

    # ENTER + UPDATE
    # Appending to the enter selection expands the update selection to include
    # entering elements; so, operations on the update selection after appending to
    # the enter selection will apply to both entering and updating nodes.
    @relations.attr('id', (d) -> return 'relation-'+d.id)
      .attr('marker-end', (d) -> return if d.direction then 'url(#arrow)' else '')

    # EXIT
    # Remove old elements as needed.
    @relations.exit().remove()

  updateNodesLabels: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    # Join new data with old elements, if any
    @nodes_labels = @nodes_labels_cont.selectAll('.node-label').data(@data_nodes)

    console.log 'updateNodesLabels', @parameters.showNodesLabel

    # ENTER
    # Create new elements as needed.
    @nodes_labels.enter().append('text')
      .attr('id', (d,i) -> return 'node-label-'+d.id)
      .attr('class', if @parameters.showNodesLabel then 'node-label' else 'node-label hide')
      .attr('dx', 0)
      .attr('dy', @getNodeLabelYPos)

    # ENTER + UPDATE
    # Appending to the enter selection expands the update selection to include
    # entering elements; so, operations on the update selection after appending to
    # the enter selection will apply to both entering and updating nodes.
    @nodes_labels.text (d) -> return d.name
    @nodes_labels.call @formatNodesLabels

    # EXIT
    # Remove old elements as needed.
    @nodes_labels.exit().remove()

  updateRelationsLabels: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    # Join new data with old elements, if any
    @relations_labels = @relations_labels_cont.selectAll('.relation-label-g').data(@data_relations_visibles)

    # ENTER
    # Create new elements as needed.
    @relations_labels.enter()
      .append('g')
        .attr('class', 'relation-label-g')
        .append('text')
          .attr('id', (d) -> return 'relation-label-'+d.id)
          .attr('class', 'relation-label')
          .attr('x', 0)
          .attr('dy', -4)
        .append('textPath')
          .attr('xlink:href',(d) -> return '#relation-'+d.id) # link textPath to label relation
          .style('text-anchor', 'middle')
          .attr('startOffset', '50%') 
          #.text((d) -> return d.relation_type)

    # ENTER + UPDATE
    # Appending to the enter selection expands the update selection to include
    # entering elements; so, operations on the update selection after appending to
    # the enter selection will apply to both entering and updating nodes.
    @relations_labels.selectAll('textPath').text((d) -> return d.relation_type)

    # EXIT
    # Remove old elements as needed.
    @relations_labels.exit().remove()

  updateForce: ->
    @force
      .nodes(@data_nodes)
      .links(@data_relations_visibles)
      .start()


  # Nodes / Relations methods
  # --------------------------

  addNodeData: (node) ->
    # check if node is present in @data_nodes
    console.log 'addNodeData', node.id, node
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
      @linkedByIndex[relation.source_id+','+relation.target_id] = true

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

  addNode: (node) ->
    console.log 'addNode', node
    @addNodeData node
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    # unfocus node to remove
    @nodes.selectAll('#node-'+node.id+' .node-circle').classed('active', false)
    @removeNodeData node
    @removeNodeRelations node

  removeNodeRelations: (node) =>
    # update data_relations_visibles removing relations with removed node
    @data_relations_visibles = @data_relations_visibles.filter (d) =>
      return d.source_id != node.id and d.target_id != node.id

  addRelation: (relation) ->
    console.log 'addRelation', relation
    @addRelationData relation

  removeRelation: (relation) ->
    console.log 'removeRelation', relation
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
    @unfocusNode()
    @nodes.selectAll('#node-'+node.id+' .node-circle').classed('active', true)

  unfocusNode: ->
    @nodes.selectAll('.node-circle.active').classed('active', false)

  setNodesColor: (d) =>
    if @parameters.nodesColor == 'qualitative'
      color = @colorQualitativeScale d.node_type  
    else if @parameters.nodesColor == 'quantitative'
      color = @colorQuantitativeScale d.node_type
    else
      color = @COLORS[@parameters.nodesColor]
    return color


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
    @container.attr 'transform', @getContainerTransform()
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
    @container.attr 'transform', @getContainerTransform()

   getContainerTransform: ->
    return 'translate(' + (@viewport.center.x+@viewport.origin.x+@viewport.x-@viewport.offsetx) + ',' + (@viewport.center.y+@viewport.origin.y+@viewport.y-@viewport.offsety) + ')scale(' + @viewport.scale + ')'


  # Config Methods
  # ---------------

  updateNodesColor: (value) =>
    @parameters.nodesColor = value
    @nodes.selectAll('.node-circle')
      .style('fill', @setNodesColor)
      .style('stroke', @setNodesColor)

  updateNodesSize: (value) =>
    console.log 'updateNodesSize', value
    @parameters.nodesSize = parseInt(value)
    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()
    # update nodes radius
    @nodes.selectAll('.node-circle').attr('r', @getNodeSize)
    # update nodes labels position
    @nodes_labels.selectAll('.first-line').attr('dy', @getNodeLabelYPos)
    # update relations arrows position
    @relations.attr 'd', @drawRelationPath

  toogleNodesLabels: (value) =>
    @nodes_labels.classed 'hide', !value
  
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

  updateRelationsCurvature: (value) ->
    @parameters.relationsCurvature = value
    @onTick()

  updateRelationsLineStyle: (value) ->
    @relations_cont.attr 'class', 'relations-cont '+@getRelationsLineStyle(value)

  getRelationsLineStyle: (value) ->
    lineStyle = switch
      when value == 0 then 'line-solid'
      when value == 1 then 'line-dashed'
      else 'line-dotted' 
    return lineStyle

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
    #@nodes.select('circle')
    #  .style('fill', (o) => return if @areNodesRelated(d, o) then @color(o.node_type) else @mixColor(@color(o.node_type), '#ffffff') )
    #
    # highlight related nodes labels
    @nodes_labels.classed 'weaken', true
    @nodes_labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)
    # highlight node relations
    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index
    # highlight node relation labels
    @relations_labels.selectAll('.relation-label').classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index

  onNodeOut: (d) =>
    #@nodes.select('circle')
    #  .style('fill', (o) => return @color(o.node_type))
    #
    @nodes_labels.classed 'weaken', false
    @nodes_labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false
    @relations_labels.selectAll('.relation-label').classed 'highlighted', false

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
    @relations.attr 'd', @drawRelationPath # (d) =>   # we need to 
    # Set relations arrow markers
    @relations.attr 'marker-end', (d) ->
      return if d.direction and d.angle >= 0 then 'url(#arrow-end)' else ''
    @relations.attr 'marker-start', (d) ->
      return if d.direction and d.angle < 0 then 'url(#arrow-start)' else ''
    # Set nodes & labels position
    @nodes.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
    @nodes_labels.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
  
  drawRelationPath: (d) =>
    # vector auxiliar methods from https://stackoverflow.com/questions/13165913/draw-an-arrow-between-two-circles
    length  = ({x,y}) -> Math.sqrt(x*x + y*y)
    sum     = ({x:x1,y:y1}, {x:x2,y:y2}) -> {x:x1+x2, y:y1+y2}
    diff    = ({x:x1,y:y1}, {x:x2,y:y2}) -> {x:x1-x2, y:y1-y2}
    prod    = ({x,y}, scalar) -> {x:x*scalar, y:y*scalar}
    div     = ({x,y}, scalar) -> {x:x/scalar, y:y/scalar}
    unit    = (vector) -> div(vector, length(vector))
    scale   = (vector, scalar) -> prod(unit(vector), scalar)
    free    = ([coord1, coord2]) -> diff(coord2, coord1)

    dx = d.target.x - d.source.x
    dy = d.target.y - d.source.y
    dist = @parameters.relationsCurvature * Math.sqrt dx*dx + dy*dy  # Calculate distance between source & target positions

    # Calculate relation angle in order to draw always convex arcs & avoid relation labels facing down
    d.angle = Math.atan2(dx,dy) # *(180/Math.PI) to convert to degrees

    # if relation has direction we use vector math to draw its path to the border of target circle
    if d.direction
      v1 = scale(free([d.source, d.target]), @getNodeSize(d.source))
      v2 = scale(free([d.source, d.target]), @getNodeSize(d.target))
      p1 = sum(d.source, v1)
      p2 = diff(d.target, v2)
      
      # Define arc sweep-flag (which defines concave or convex) based on angle parameter
      if d.angle >= 0
        path = 'M ' + d.source.x + ' ' + d.source.y + ' A ' + dist + ' ' + dist + ' 0 0 1 ' + p2.x + ' ' + p2.y
      else
        path = 'M ' + p2.x + ' ' + p2.y + ' A ' + dist + ' ' + dist + ' 0 0 0 ' + d.source.x + ' ' + d.source.y
    # if relation has no direction we draw path from center to center
    else    
      # Define arc sweep-flag (which defines concave or convex) based on angle parameter
      if d.angle >= 0
        path = 'M ' + d.source.x + ' ' + d.source.y + ' A ' + dist + ' ' + dist + ' 0 0 1 ' + d.target.x + ' ' + d.target.y
      else
        path = 'M ' + d.target.x + ' ' + d.target.y + ' A ' + dist + ' ' + dist + ' 0 0 0 ' + d.source.x + ' ' + d.source.y
      
    return path

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

  getNodeLabelYPos: (d) =>
    return parseInt(@svg.select('#node-'+d.id).select('.node-circle').attr('r'))+13

  getNodeSize: (d) =>
    # if nodesSize = 1, set size based on node relations
    if @parameters.nodesSize == 1
      size = 5+15*(@nodes_relations_size[d.id]/@data_relations_visibles.max)
    else
      size = @parameters.nodesSize
    return size

  setNodesRelationsSize: =>
    @nodes_relations_size = {}
    # initialize nodes_relations_size object with all nodes with zero value
    @data_nodes.forEach (d) =>
      @nodes_relations_size[d.id] = 0
    # increment each node value which has a relation
    @data_relations_visibles.forEach (d) =>
      @nodes_relations_size[d.source_id] += 1
      @nodes_relations_size[d.target_id] += 1
    @data_relations_visibles.max = d3.max d3.entries(@nodes_relations_size), (d) -> return d.value
    console.log 'setNodesRelationsSize', @nodes_relations_size, @data_nodes

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
        if tspan.node().getComputedTextLength() > 100
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