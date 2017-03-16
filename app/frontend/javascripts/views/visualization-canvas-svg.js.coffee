d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvasSVG extends VisualizationCanvasBase

  defs:                   null

  setupCanvas: ->

    canvasDrag = d3.drag()
      .on('start',  @onCanvasDragStart)
      .on('drag',   @onCanvasDragged)
      .on('end',    @onCanvasDragEnd)

    # Setup SVG
    @canvas = d3.select(@el).append('svg')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      .call canvasDrag

    # Define Arrow Markers
    @defs = @canvas.append('defs')
    # Setup arrow 
    @defs.append('marker')
        .attr 'id', 'arrow'
        .attr 'class', 'arrow-marker'
        .attr 'viewBox', '-8 -10 8 20'
        .attr 'refX', 2
        .attr 'refY', 0
        .attr 'markerWidth', 10
        .attr 'markerHeight', 10
        .attr 'orient', 'auto'
      .append 'path'
        .attr 'd', 'M -10 -8 L 0 0 L -10 8'


  setupContainers: ->
    # Setup containers
    @container             = @canvas.append('g')
    @relations_cont        = @container.append('g').attr('class', 'relations-cont '+@getRelationsLineStyle(@parameters.relationsLineStyle))
    @relations_labels_cont = @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_cont            = @container.append('g').attr('class', 'nodes-cont')
    @nodes_labels_cont     = @container.append('g').attr('class', 'nodes-labels-cont')


  clear: ->
    super()
    # Clear all containers
    @container.remove()
    @relations_cont.remove()
    @relations_labels_cont.remove()
    @nodes_cont.remove()
    @nodes_labels_cont.remove()


  updateImages: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    patterns = @defs.selectAll('filter').data(@data_nodes.filter (d) -> return d.image != null)

    # EXIT old elements not present in new data
    patterns.exit().remove()

    # UPDATE old elements present in new data
    patterns.attr('id', (d) -> return 'node-pattern-'+d.id)
      .selectAll('image')
        .attr('xlink:href', (d) => return @getImage(d))
    
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
        .attr('xlink:href', (d) => return @getImage(d))


  updateNodes: ->
    # Set nodes size
    @data_nodes.forEach (d) =>
      @setNodeSize(d)

    # Reorder nodes data if size is dynamic (in order to add bigger nodes after small ones)
    if @parameters.nodesSize == 1
      @data_nodes.sort @sortNodes

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
      .attr  'r',       (d) -> return d.size
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeStroke

    # ENTER new elements present in new data.
    @nodes.enter().append('circle')
      .attr  'id',      (d) -> return 'node-'+d.id
      .attr  'class',   (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       (d) -> return d.size
      # set position at viewport center
      .attr  'cx',      @viewport.center.x
      .attr  'cy',      @viewport.center.y
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeStroke
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
    @relations
      .attr 'id',           (d) -> return 'relation-'+d.id
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      .attr 'marker-end',   (d) -> return if d.direction then 'url(#arrow)' else ''

    # ENTER new elements present in new data.
    @relations.enter().append('path')
      .attr 'id',           (d) -> return 'relation-'+d.id
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      .attr 'marker-end',   (d) -> return if d.direction then 'url(#arrow)' else ''

    @relations = @relations_cont.selectAll('.relation')

  updateNodesLabels: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes_labels = @nodes_labels_cont.selectAll('.node-label').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes_labels.exit().remove()

    # UPDATE old elements present in new data
    @nodes_labels
      .attr 'id',    (d,i) -> return 'node-label-'+d.id
      .attr 'class', 'node-label'
      .attr 'dy',    @getNodeLabelYPos
      .text (d) -> return d.name
      .call @formatNodesLabels

    # ENTER new elements present in new data
    @nodes_labels.enter().append('text')
      .attr 'id',    (d,i) -> return 'node-label-'+d.id
      .attr 'class', 'node-label'
      .attr 'dx',    0
      .attr 'dy',    @getNodeLabelYPos
      .text (d) -> return d.name
      .call @formatNodesLabels

    @nodes_labels = @nodes_labels_cont.selectAll('.node-label')

    # we need to update labels class after call to formatNodesLabels
    # in order to use same font-size for getComputedTextLength
    @nodes_labels.attr 'class', @getNodeLabelClass

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
        #.attr  'x', (d) -> return (d.source.x+d.target.x)*0.5
        #.attr  'y', (d) -> return (d.source.y+d.target.y)*0.5
        .attr  'dy', '-0.3em'
        .attr  'transform', @getRelationLabelTransform
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


  focusNode: (node) ->
    if @node_active
      # clear previous focused nodes
      @nodes_cont.selectAll('#node-'+@node_active.id)
        .style 'stroke',  @getNodeStroke
      @node_active = null
      # force node over
      @onNodeOver node
    # set node active
    @node_active = node
    @nodes_cont.selectAll('.node.active')
      .classed 'active', false
    @nodes_cont.selectAll('#node-'+node.id)
      .classed 'active', true
      .style   'stroke', @getNodeStroke
    @updateRelationsLabelsData()
    # center viewport in node
    @centerNode node

  unfocusNode: ->
    if @node_active
      @nodes_cont.selectAll('#node-'+@node_active.id)
        .style 'stroke',  @getNodeStroke
      @nodes_cont.selectAll('.node.active')
        .classed 'active', false
      @node_active = null
      @onNodeOut()
      # center viewport
      @centerNode null

  centerNode: (node) ->
    if node
      @viewport.offsetnode.x = (@viewport.scale * (node.get('x') - @viewport.center.x)) + @viewport.x + 175 # 175 = $('.visualization-graph-info').height() / 2
      @viewport.offsetnode.y = (@viewport.scale * (node.get('y') - @viewport.center.y)) + @viewport.y
    else
      @viewport.offsetnode.x = @viewport.offsetnode.y = 0
    @rescaleTransition()


  # Resize Methods
  # ---------------

  rescale: ->
    @container.attr       'transform', @getContainerTransform()
    translateStr = 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'
    @relations_cont.attr        'transform', translateStr
    @relations_labels_cont.attr 'transform', translateStr
    @nodes_cont.attr            'transform', translateStr
    @nodes_labels_cont.attr     'transform', translateStr

  rescaleTransition: ->
    @container.transition()
      .duration 500
      .ease     d3.easeQuadOut
      .attr     'transform', @getContainerTransform()

  
  # Config Methods
  # ---------------

  updateNodesColorValue: =>
    super()
    @nodes
      .style 'fill',   @getNodeFill
      .style 'stroke', @getNodeStroke


  updateNodesSizeValue: =>
    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      if @parameters.nodesSizeColumn == 'relations'
        @setNodesRelations()
      @setScaleNodesSize()
      @updateNodes()
      @updateForce true
    else
      # set nodes size & update nodes radius
      @setNodesSize()
      @nodes.attr 'r', (d) -> return d.size
    # # update nodes labels position
    @nodes_labels.attr 'class', @getNodeLabelClass
    @nodes_labels.selectAll('.first-line')
      .attr 'dy', @getNodeLabelYPos
    # update relations arrows position
    @relations.attr 'd', @drawRelationPath

  toogleNodesLabel: (value) =>
    @nodes_labels.classed 'hide', !value

  toogleNodesLabelComplete: (value) =>
    @nodes_labels.attr 'class', @getNodeLabelClass


  updateRelationsLineStyle: (value) ->
    @relations_cont.attr 'class', 'relations-cont '+@getRelationsLineStyle(value)


  # Navigation Methods
  # ---------------
  
  zoom: (value) ->
    super(value)
    @container
      .transition()
        .duration 500
        .attr     'transform', @getContainerTransform()


  # Events Methods
  # ---------------

  # Canvas Drag Events
  onCanvasDragStart: =>
    @canvas.style('cursor','move')

  onCanvasDragEnd: =>
    @canvas.style('cursor','default')
    super()

  onNodeOver: (d) =>
    # skip if any node is active
    if @node_active
      return
    # add relations labels  
    @updateRelationsLabels @getNodeRelations(d.id)
    # highlight related nodes labels
    @nodes_labels.classed 'weaken', true
    @nodes_labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)
    # highlight node relations
    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source_id == d.id || o.target_id == d.id


  onNodeOut: (d) =>
    # skip if any node is active
    if @node_active
      return
    # clear relations labels
    @updateRelationsLabels {}
    # clear nodes & relations classes
    @nodes_labels.classed 'weaken', false
    @nodes_labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false

  onNodeClick: (d) =>
    # Avoid trigger click on dragEnd
    if d3.event.defaultPrevented 
      return
    Backbone.trigger 'visualization.node.showInfo', {node: d.id}

  onNodeDoubleClick: (d) =>
    # unfix the node position when the node is double clicked
    @force.unfix d


  # Tick Function
  onTick: =>
    #console.log 'on tick'
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
        .attr 'transform', @getRelationLabelTransform
  

  # Auxiliar Methods
  # ----------------

  getNodeLabelYPos: (d) =>
    return parseInt(@nodes_cont.select('#node-'+d.id).attr('r'))+13
    
  formatNodesLabels: (nodes) =>
    nodes.each () ->
      node = d3.select(this)
      name = node.text()
      if name != null and name != ''
        words = name.trim().split(/\s+/).reverse()
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
          if tspan.node().getComputedTextLength() > 130
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

module.exports = VisualizationCanvasSVG