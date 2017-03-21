d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvas extends VisualizationCanvasBase

  context:      null
  quadtree:     null

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
    
    # Reorder nodes data if size is dynamic (in order to add bigger nodes after small ones)
    if @parameters.nodesSize == 1
      @data_nodes.sort @sortNodes

  setNodeState: (d) =>
    if @node_hovered
      if @areNodesRelated(d, @node_hovered)
        d.state = 1  # highlighted state
      else
        d.state = -1 # weaken state
    else
      d.state = 0    # normal state

  setNodeFill: (d) =>
    if d.disabled
      d.fill = '#d3d7db'
    #else if @parameters.showNodesImage and d.image != null
    #  fill = 'url(#node-pattern-'+d.id+')'
    else if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      d.fill = @color_scale d[@parameters.nodesColorColumn] 
    else
      d.fill = @COLOR_SOLID[@parameters.nodesColor]

  setNodeStroke: (d) =>
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

  setNodeFont: (d) =>
    if @parameters.nodesSize != 1
      d.fontSize = 12
      d.fontColor = '#404040'
    else
      val = @scale_labels_size d[@parameters.nodesSizeColumn]
      d.fontSize = [11,12,13,15][val]
      d.fontColor = ['#676767','#5a5a5a','#4d4d4d','#404040'][val]

  setRelationState: (d) ->
    if @node_active 
      if d.source_id == @node_active.id or d.target_id == @node_active.id
        d.state = 1  # highlighted state
      else
        d.state = -1 # weaken state
    else if @node_hovered
      if d.source_id == @node_hovered.id or d.target_id == @node_hovered.id
        d.state = 1  # highlighted state
      else
        d.state = -1 # weaken state
    else
      d.state = 0    # normal state

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
    
    @drawRelations()
    
    if @node_active or @node_hovered
      @drawRelationsLabels()
    
    @drawNodes()
    
    if @parameters.showNodesLabel or @node_hovered
      @drawNodesLabels()

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

  drawNodesLabels: ->
    # set styles
    @context.lineWidth    = 1
    @context.strokeStyle  = 'rgba(255,255,255,0.85)'
    @context.textAlign    = 'center'
    @context.textBaseline = 'top'
    @data_nodes
      .filter (d) -> d.state != -1 # don't draw labels of weaken nodes
      .forEach (d) =>
        @context.fillStyle  = d.fontColor
        @context.font       = '300 '+d.fontSize+'px Montserrat'
        @context.strokeText d.name, d.x, d.y+d.size+1
        @context.fillText   d.name, d.x, d.y+d.size

  drawRelations: ->
    # make stroke color dynamic based on nodes state !!!
    @data_relations_visibles.forEach (link) =>
      @context.strokeStyle = link.color
      @context.lineWidth = 1
      @context.beginPath()
      @context.moveTo link.source.x, link.source.y
      @context.lineTo link.target.x, link.target.y
      @context.stroke()
      @context.closePath()

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

  rescaleTransition: ->
    # implement transition here
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
    @onCanvasMove()

  onCanvasMove: =>
    # get mouse point
    mouse = d3.mouse @canvas.node()
    @setQuadtree()
    node = @quadtree.find mouse[0]-@viewport.center.x-@viewport.translate.x, mouse[1]-@viewport.center.y-@viewport.translate.y, @viewport.scale*40
    
    # check @node_active !!!
    #if @node_active

    # clear node hovered if node is undefined
    if node == undefined
      @updateNodeHovered null
      return

    if @node_hovered and @node_hovered.id == node.id
      return
    @updateNodeHovered node

  onCanvasLeave: (e) =>
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
      @data_nodes.splice @data_nodes.indexOf(@node_hovered), 1
      @data_nodes.push @node_hovered
    # update nodes state & stroke
    @data_nodes.forEach (d) =>
      @setNodeState d
      @setNodeStroke d
    # update relations colors
    @data_relations_visibles.forEach (d) =>
      @setRelationState d
      @setRelationColor d
    # sort relations to put highlighted on top
    # that's make some weird effects in force layout during animation
    #@data_relations_visibles.sort @sortRelations
    # update canvas if force layout stoped
    @redraw()


module.exports = VisualizationCanvas