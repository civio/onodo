d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvas extends VisualizationCanvasBase

  LABEL_MAX_WIDTH: 130
  context:         null
  quadtree:        null

  # Setup methods
  # -------------------

  setupCanvas: ->

    # set canvas drag
    canvasDrag = d3.drag()
      .on 'start', @onCanvasDragStart
      .on 'drag',  @onCanvasDragged
      .on 'end',   @onCanvasDragEnd

    # Setup canvas
    @canvas = d3.select(@el).append('canvas')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      .on   'mouseenter', @onCanvasEnter
      .on   'mousemove',  @onCanvasMove
      .on   'mouseleave', @onCanvasLeave
      .on   'click',      @onCanvasClick
      .call canvasDrag

    # Setup canvas context
    @context = @canvas.node().getContext('2d')

  setupContainers: ->
    # Setup a custom element container that will not be attached to the DOM, to which we can bind the data
    customElement = document.createElement 'custom'
    @container    = d3.select customElement

  setQuadtree: ->
    @quadtree = d3.quadtree()
      .extent [[0, 0], [@viewport.scale*@viewport.width, @viewport.scale*@viewport.height]]
      .x (d) => @viewport.scale*d.x
      .y (d) => @viewport.scale*d.y
      .addAll @data_nodes


  # Nodes methods
  # -------------------
  
  updateNodes: ->
    #console.log 'updateNodes'
    @data_nodes.forEach (d) =>
      @setNodeState d
      @setNodeSize d
      @setNodeFill d
      @setNodeStroke d
      @setNodeFont d
      @setNodeLabel d
      @setNodeImage d
    # Reorder nodes data if size is dynamic (in order to add bigger nodes after small ones)
    if @parameters.nodesSize == 1
      @data_nodes.sort @sortNodes

  updateNodesState: ->
    @data_nodes.forEach (d) =>
      @setNodeState d
      @setNodeStroke d
    @data_relations_visibles.forEach (d) =>
      @setRelationState d
      @setRelationColor d

  setNodeState: (d) ->
    d.state = 0    # normal state
    if @node_active or @node_hovered
      d.state = -1 # weaken state
      if @node_active and @areNodesRelated(d, @node_active)
        d.state = 1 # highlighted state
      if @node_hovered and @areNodesRelated(d, @node_hovered)
        d.state = 1 # highlighted state

  setNodeFill: (d) ->
    if d.disabled
      d.fill = '#d3d7db'
    else if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      d.fill = @color_scale d[@parameters.nodesColorColumn] 
    else
      d.fill = @COLOR_SOLID[@parameters.nodesColor]

  setNodeImage: (d) ->
    if @parameters.showNodesImage
      d.img = @getImage d
      if d.img
        d.imgObj = new Image()
        d.imgObj.src = d.img

  setNodeStroke: (d) ->
    if @node_active and d.id == @node_active.id
      d.strokeWidth = 20
      color = d3.rgb d.fill
      d.stroke = 'rgba('+color.r+','+color.g+','+color.b+',0.5)'
    else if @node_hovered and d.id == @node_hovered.id
      d.strokeWidth = 8
      color = d3.rgb d.fill
      d.stroke = 'rgba('+color.r+','+color.g+','+color.b+',0.5)'
    else
      d.strokeWidth = 1
      d.stroke = 'transparent'

  setNodeFont: (d) ->
    if @parameters.nodesSize != 1
      d.fontSize = 12
      d.fontColor = '#404040'
    else
      val = @scale_labels_size d[@parameters.nodesSizeColumn]
      d.fontSize = [11,12,13,15][val]
      d.fontColor = ['#676767','#5a5a5a','#4d4d4d','#404040'][val]

  setNodeLabel: (d) ->
    @context.font = '300 '+d.fontSize+'px Montserrat'
    metrics = @context.measureText d.name
    if metrics.width <= @LABEL_MAX_WIDTH
      d.short_label = d.name
      d.long_label  = null
    else
      d.long_label  = @getNodeLongLabel d.name
      d.short_label = d.long_label[0]+' ...'
      
  getNodeLongLabel: (text) ->
    lines      = []
    line       = ''
    words      = text.split ' '
    words.forEach (word, i) =>
      if i > 0
        test = line + ' ' + word
        metrics = @context.measureText test
        if metrics.width > @LABEL_MAX_WIDTH
          lines.push line
          line = word
        else
          line = test
      else
        test = line = word
    lines.push line
    return lines

  setRelationState: (d) ->
    d.state = 0    # normal state
    if @node_active or @node_hovered
      d.state = -1 # weaken state
      if @node_active and (d.source_id == @node_active.id or d.target_id == @node_active.id)
        d.state = 1 # highlighted state
      if @node_hovered and (d.source_id == @node_hovered.id or d.target_id == @node_hovered.id)
        d.state = 1 # highlighted state

  setRelationColor: (d) ->
    if d.state == 0
      d.color = '#cccccc' # normal state
    else if d.state == 1
      d.color = '#b0b0b0' # highlighted state
    else
      d.color = '#eeeeee' # weaken state
      

  # Drawing methods
  # -------------------

  redraw: ->
    if @force.alpha() < @force.alphaMin()
      @onTick()

  # Tick Function
  onTick: =>
    # clear canvas
    @context.clearRect 0, 0, @viewport.width, @viewport.height
    @context.save()
    # translate & scale viewport
    @context.translate @viewport.center.x+@viewport.translate.x, @viewport.center.y+@viewport.translate.y
    @context.scale @viewport.scale, @viewport.scale
    # draw relations
    @drawRelations()
    # draw relations labels
    if @node_active or @node_hovered
      @drawRelationsLabels()
    # draw nodes
    @drawNodes()
    # draw nodes labels
    if @parameters.showNodesLabel or @node_active or @node_hovered
      @drawNodesLabels()
    # context restore
    @context.restore()

  drawNodes: ->
    @data_nodes.forEach (d) =>
      # set styles
      @context.lineWidth = d.strokeWidth
      @context.strokeStyle = d.stroke
      @context.fillStyle = d.fill
      # draw node
      @context.beginPath()
      @context.moveTo d.x, d.y
      @context.arc d.x, d.y, d.size, 0, 2*Math.PI, true
      @context.fill()
      @context.stroke()
      @context.closePath()
      # draw image
      if d.img
        @context.save()
        @context.clip()
        @context.drawImage d.imgObj, d.x-d.size, d.y-d.size, 2*d.size, 2*d.size
        @context.restore()

  drawNodesLabels: ->
    # set styles
    @context.lineWidth    = 1
    @context.strokeStyle  = 'rgba(255,255,255,0.85)'
    @context.textAlign    = 'center'
    @context.textBaseline = 'top'
    @data_nodes
      .filter (d) -> d.state != -1 # don't draw labels of weaken nodes
      .forEach @drawNodeLabel

  drawNodeLabel: (d) =>
    @context.fillStyle = d.fontColor
    @context.font      = '300 '+d.fontSize+'px Montserrat'
    if (@parameters.showNodesLabelComplete or @node_hovered or @node_active) and d.long_label
      d.long_label.forEach (line, i) =>
        @context.strokeText line, d.x, d.y+d.size+(i*d.fontSize)+1
        @context.fillText   line, d.x, d.y+d.size+(i*d.fontSize)
    else
      @context.strokeText d.short_label, d.x, d.y+d.size+1
      @context.fillText   d.short_label, d.x, d.y+d.size

  drawRelations: ->
    # make stroke color dynamic based on nodes state !!!
    @context.save()
    @context.lineWidth = 1
    if @parameters.relationsLineStyle == 1
      @context.lineCap = 'square'
      @context.setLineDash [4, 3]
    else if @parameters.relationsLineStyle == 2
      @context.lineCap = 'round'
      @context.setLineDash [0.25, 3]
    @data_relations_visibles.forEach (link) =>
      @context.strokeStyle = link.color
      @context.beginPath()
      @context.moveTo link.source.x, link.source.y
      @context.lineTo link.target.x, link.target.y
      @context.stroke()
      @context.closePath()
    @context.restore()

  drawRelationsLabels: ->
    @context.textAlign    = 'center'
    @context.textBaseline = 'bottom'
    @context.fillStyle    = '#aaaaaa'
    @context.font         = '300 9px Montserrat'
    @data_relations_visibles
      .filter (d) -> d.state == 1 and d.relation_type # only draw labels of highlighted relations
      .forEach (d) =>
        angle = Math.atan2(d.target.y - d.source.y, d.target.x - d.source.x)
        if angle > Math.PI/2 or angle < -Math.PI/2
          angle += Math.PI
        @context.save()
        @context.translate (d.source.x+d.target.x)*0.5, (d.source.y+d.target.y)*0.5
        @context.rotate angle
        @context.fillText d.relation_type, 0, 0
        @context.restore()


  # Resize & Navigation Methods
  # ---------------

  rescale: ->
    @viewport.translate.x = @viewport.origin.x + @viewport.x - @viewport.offsetx - @viewport.offsetnode.x
    @viewport.translate.y = @viewport.origin.y + @viewport.y - @viewport.offsety - @viewport.offsetnode.y
    @redraw()

  rescaleTransition: (offsetX, offsetY) ->
    interpolateX = d3.interpolateNumber @viewport.offsetnode.x, offsetX
    interpolateY = d3.interpolateNumber @viewport.offsetnode.y, offsetY
    t = d3.timer (elapsed) =>
      if elapsed < 300
        val = elapsed/300
        @viewport.offsetnode.x = interpolateX val
        @viewport.offsetnode.y = interpolateY val
      else
        @viewport.offsetnode.x = offsetX
        @viewport.offsetnode.y = offsetY
        t.stop()
      @rescale()

  zoom: (value) ->
    super(value)
    @redraw()


  # Canvas Mouse Events
  # -------------------

  # Canvas Drag Events
  onCanvasDragStart: =>
    if @node_hovered
      @force
        .alphaTarget 0.1
        .restart()
    unless @node_hovered
      @canvas.style 'cursor', 'move'

  onCanvasDragged: =>
    if @node_hovered
      @node_hovered.fx = (d3.event.x - @viewport.center.x - @viewport.translate.x) / @viewport.scale
      @node_hovered.fy = (d3.event.y - @viewport.center.y - @viewport.translate.y) / @viewport.scale
      @redraw()
    else
      @viewport.x  += d3.event.dx
      @viewport.y  += d3.event.dy
      @viewport.dx += d3.event.dx
      @viewport.dy += d3.event.dy
      @rescale()

  onCanvasDragEnd: =>
    if @node_hovered
      @force.alphaTarget 0
    else
      @canvas.style 'cursor','default'
      #@force.alphaTarget(0)
      # Skip if viewport has no translation
      if @viewport.dx == 0 and @viewport.dy == 0
        Backbone.trigger 'visualization.node.hideInfo'
        return
      # TODO! Add viewportMove action to history
      @viewport.dx = @viewport.dy = 0;

  # Canvas Mouse Events
  onCanvasEnter: =>
    #if @node_active
    #  return
    @onCanvasMove()

  onCanvasMove: =>
    #if @node_active
    #  return
    # get mouse point
    mouse = d3.mouse @canvas.node()
    @setQuadtree()
    node = @quadtree.find mouse[0]-@viewport.center.x-@viewport.translate.x, mouse[1]-@viewport.center.y-@viewport.translate.y, @viewport.scale*40
    
    # clear node hovered if node is undefined
    if node == undefined
      @updateNodeHovered null
      return

    if @node_hovered and @node_hovered.id == node.id
      return
    @updateNodeHovered node

  onCanvasLeave: (e) =>
    #if @node_active
    #  return
    @updateNodeHovered null

  onCanvasClick: (e) =>
    # Avoid trigger click on dragEnd
    #if d3.event.defaultPrevented 
    #  return
    if @node_hovered
      Backbone.trigger 'visualization.node.showInfo', {node: @node_hovered.id }
    else
      Backbone.trigger 'visualization.node.hideInfo'

  updateNodeHovered: (node) ->
    @node_hovered = node
    @data_nodes.sort @sortNodes
    # move node hovered at the end of the data nodes array
    if @node_hovered
      @canvas.style 'cursor', 'pointer'
      @data_nodes.splice @data_nodes.indexOf(@node_hovered), 1
      @data_nodes.push @node_hovered
    else
      @canvas.style 'cursor', 'auto'
    # update nodes state & stroke
    @updateNodesState()
    # sort relations to put highlighted on top
    # that's make some weird effects in force layout during animation
    #@data_relations_visibles.sort @sortRelations
    # update canvas if force layout stoped
    @redraw()

  focusNode: (node) ->
    if @node_active
      @node_active = null
    # set node active
    @node_active = node
    @node_hovered = null
    @canvas.style 'cursor', 'auto'
    # update nodes state & stroke
    @updateNodesState()
    # center viewport in node
    @centerNode node

  unfocusNode: ->
    if @node_active
      @node_active = null
      # update nodes state & stroke
      @updateNodesState()
      # center viewport
      @centerNode null

  centerNode: (node) ->
    if node
      offsetX = (@viewport.scale * node.get('x')) + @viewport.x + 175 # 175 = $('.visualization-graph-info').height() / 2
      offsetY = (@viewport.scale * node.get('y')) + @viewport.y
    else
      offsetX = offsetY = 0
    @rescaleTransition offsetX, offsetY


module.exports = VisualizationCanvas