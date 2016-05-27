d3 = require 'd3'

class VisualizationGraphCanvasTest extends Backbone.View

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

    # # Setup force
    # @force = d3.layout.force()
    #   .linkDistance @parameters.linkDistance
    #   .linkStrength @parameters.linkStrength
    #   .friction     @parameters.friction
    #   .charge       @parameters.charge
    #   .theta        @parameters.theta
    #   .gravity      @parameters.gravity
    #   .size         [@viewport.width, @viewport.height]
    #   .on           'tick', @onTick

    # @forceDrag = @force.drag()
    #   .on('dragstart',  @onNodeDragStart)
    #   .on('dragend',    @onNodeDragEnd)

    # Setup SVG
    @svg = d3.select('svg')
        .attr('width',  @viewport.width)
        .attr('height', @viewport.height)
        #.call(d3.behavior.drag()
        #  .on('drag',       @onCanvasDrag)
        #  .on('dragstart',  @onCanvasDragStart)
        #  .on('dragend',    @onCanvasDragEnd))

    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()  # initialize nodes_relations_size array

    # Setup containers
    @container            = @svg.append('g')
    @relations_cont       = @container.append('g').attr('class', 'relations-cont')
    @nodes_cont           = @container.append('g').attr('class', 'nodes-cont')
    @relations_labels_cont= @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_labels_cont    = @container.append('g').attr('class', 'nodes-labels-cont')
    
    @rescale()  # Translate svg

  initializeData: (data) ->

    console.log 'initializeData'

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d

    # Setup color ordinal scale domain
    #@colorQualitativeScale.domain   data.nodes.map( (d) -> d.node_type )
    #@colorQuantitativeScale.domain  data.nodes.map( (d) -> d.node_type )

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

  render: ->
    console.log 'render canvas'
    @updateRelations()
    @updateRelationsLabels()
    @updateNodes()
    @updateNodesLabels()
    @updateForce()

  updateNodes: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    @nodes = @nodes_cont.selectAll('.node').data(@data_nodes)

    # ENTER
    @nodes.enter().append('circle')
      # .on   'mouseover',  @onNodeOver
      # .on   'mouseout',   @onNodeOut
      # .on   'click',      @onNodeClick
      # .on   'dblclick',   @onNodeDoubleClick
      # .call @forceDrag

    # ENTER + UPDATE
    @nodes.attr('id', (d) -> return 'node-'+d.id)
      .attr 'class',    (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       @getNodeSize
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeColor
      
    # EXIT
    @nodes.exit().remove()

  updateRelations: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    @relations = @relations_cont.selectAll('.relation').data(@data_relations_visibles)

    # ENTER
    @relations.enter().append('path')

    # ENTER + UPDATE
    @relations.attr('id', (d) -> return 'relation-'+d.id)
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      .attr 'marker-end',   @getRelationMarkerEnd
      .attr 'marker-start', @getRelationMarkerStart

    # EXIT
    @relations.exit().remove()

  updateNodesLabels: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    @nodes_labels = @nodes_labels_cont.selectAll('.node-label').data(@data_nodes)

    # ENTER
    @nodes_labels.enter().append('text')
      .attr 'id',     (d,i) -> return 'node-label-'+d.id
      .attr 'dx',     0
      .attr 'dy',     @getNodeLabelYPos

    # ENTER + UPDATE
    @nodes_labels
      .attr 'class', @getNodeLabelClass
      .text (d) -> return d.name
      .call @formatNodesLabels

    # EXIT
    @nodes_labels.exit().remove()

  updateRelationsLabels: ->
    # Use General Update Pattern I (https://bl.ocks.org/mbostock/3808218)

    # DATA JOIN
    @relations_labels = @relations_labels_cont.selectAll('.relation-label').data(@data_relations_visibles)

    # ENTER
    @relations_labels.enter()
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
    @relations_labels.selectAll('textPath').text((d) -> return d.relation_type)

    # EXIT
    @relations_labels.exit().remove()

  updateForce: ->
    @force
      .nodes(@data_nodes)
      .links(@data_relations_visibles)
      .start()


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
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    console.log 'removeNode', node
    # unfocus node to remove
    @nodes.selectAll('#node-'+node.id).classed('active', false)
    @removeNodeData node
    @removeNodeRelations node

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

  removeRelation: (relation) ->
    console.log 'removeRelation', relation
    @removeRelationData relation
    # update nodes relations size if needed to take into acount the removed relation
    if @parameters.nodesSize == 1
      @setNodesRelationsSize()

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
    @nodes_cont.selectAll('#node-'+node.id).classed('active', true)

  unfocusNode: ->
    @nodes_cont.selectAll('.active').classed('active', false)


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
    @relations_labels.classed 'highlighted', (o) => return o.source.index == d.index || o.target.index == d.index

  onNodeOut: (d) =>
    #@nodes.select('circle')
    #  .style('fill', (o) => return @color(o.node_type))
    #
    @nodes_labels.classed 'weaken', false
    @nodes_labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false
    @relations_labels.classed 'highlighted', false

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
    # Set relations path & arrow markers
    @relations
      .attr('d', @drawRelationPath)
      #.attr('marker-end', @getRelationMarkerEnd)
      #.attr('marker-start', @getRelationMarkerStart)
    # Set nodes & labels position
    @nodes.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
    @nodes_labels.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
  
  drawRelationPath: (d) =>
  

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
    # if @parameters.nodesColor == 'qualitative'
    #    color = @colorQualitativeScale d.node_type  
    #  else if @parameters.nodesColor == 'quantitative'
    #    color = @colorQuantitativeScale d.node_type
    #  else
    #    color = @COLORS[@parameters.nodesColor]
    color = '#333'
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


module.exports = VisualizationGraphCanvasTest