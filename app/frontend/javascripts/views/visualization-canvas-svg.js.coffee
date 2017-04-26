d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvasSVG extends VisualizationCanvasBase

  defs:                   null

  container:              null
  nodes_cont:             null
  nodes_labels_cont:      null
  relations_cont:         null
  relations_labels_cont:  null
  nodes:                  null
  nodes_labels:           null
  relations:              null
  relations_labels:       null

  degrees_const:          180 / Math.PI


  # Setup methods
  # -------------------

  setupCanvas: ->
    # Setup SVG
    @canvas = d3.select(@el).append('svg')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
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
    # Setup containers
    @container             = @canvas.append('g')
    @relations_cont        = @container.append('g').attr('class', 'relations-cont '+@getRelationsLineStyle(@parameters.relationsLineStyle))
    @relations_labels_cont = @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_cont            = @container.append('g').attr('class', 'nodes-cont')
    @nodes_labels_cont     = @container.append('g').attr('class', 'nodes-labels-cont')

  render: ( restarForce ) ->
    @updateImages()
    @updateRelations()
    super()

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

  getContainerTransform: ->
    return 'translate(' + (@viewport.center.x+@viewport.origin.x+@viewport.x-@viewport.offsetnode.x) + ',' + (@viewport.center.y+@viewport.origin.y+@viewport.y-@viewport.offsetnode.y) + ')scale(' + @viewport.scale + ')'
  

  # Events Methods
  # ---------------

  # Tick Function
  onTick: =>
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

    if d.direction
      v2 = scale free([d.source, d.target]), d.target.size
      p2 = diff d.target, v2
      return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + p2.x + ' ' + p2.y
    else
      return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y

  getRelationLabelTransform: (d) =>
    x = (d.source.x+d.target.x)*0.5
    y = (d.source.y+d.target.y)*0.5
    angle = @getAngleBetweenPoints(d.source, d.target)
    if angle > 90 or angle < -90
      angle += 180
    return "translate(#{ x },#{ y }) rotate(#{ angle })"

  getRelationsLineStyle: (value) ->
    lineStyle = switch
      when value == 0 then 'line-solid'
      when value == 1 then 'line-dashed'
      else 'line-dotted' 
    return lineStyle
  

  # Auxiliar Methods
  # ----------------

  getAngleBetweenPoints: (p1, p2) ->
    return Math.atan2(p2.y - p1.y, p2.x - p1.x) * @degrees_const
    #return Math.acos( (p1.x * p2.x + p1.y * p2.y) / ( Math.sqrt(p1.x*p1.x + p1.y*p1.y) * Math.sqrt(p2.x*p2.x + p2.y*p2.y) ) ) * 180 / Math.PI

  getNodeLabelYPos: (d) =>
    return parseInt(@nodes_cont.select('#node-'+d.id).attr('r'))+13

  getNodeLabelClass: (d) =>
    #console.log 'getNodeLabelClass', @parameters.nodesSize 
    str = 'node-label'
    if !@parameters.showNodesLabel
      str += ' hide'
    if @parameters.showNodesLabelComplete 
      str += ' complete'
    if d.disabled
      str += ' disabled'
    if @parameters.nodesSize == 1
      str += ' size-'+@scale_labels_size(d[@parameters.nodesSizeColumn])
    return str

  getNodeStroke: (d) =>
    if @node_active and d.id == @node_active.id
      if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
        color = @scale_color d[@parameters.nodesColorColumn]
      else
        color = @COLOR_SOLID[@parameters.nodesColor]
    else if @node_hovered and d.id == @node_hovered.id
      if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
        color = @scale_color d[@parameters.nodesColorColumn]
      else
        color = @COLOR_SOLID[@parameters.nodesColor]
    else
      color = 'transparent'
    return color

  getNodeFill: (d) =>
    if d.disabled
      fill = '#d3d7db'
    else if @parameters.showNodesImage and d.image != null
      fill = 'url(#node-pattern-'+d.id+')'
    else if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      fill = @scale_color d[@parameters.nodesColorColumn] 
    else
      fill = @COLOR_SOLID[@parameters.nodesColor]
    return fill
    
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