d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvas extends VisualizationCanvasBase

  context:      null
  quadtree:     null

  # Setup methods
  # -------------------

  setupCanvas: ->
    # Setup canvas
    @canvas = d3.select(@el).append('canvas')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      .on   'mouseenter', @onCanvasEnter
      .on   'mousemove',  @onCanvasMove
      .on   'mouseleave', @onCanvasLeave
      .on   'click',      @onCanvasClick
      #.call canvasDrag
    # Setup canvas context
    @context = @canvas.node().getContext('2d')

  setupContainers: ->
    # Setup a custom element container that will not be attached to the DOM, to which we can bind the data
    customElement = document.createElement 'custom'
    @container    = d3.select customElement

  setQuadtree: ->
    @quadtree = d3.quadtree()
      .extent [[-1, -1], [@viewport.width+1, @viewport.height+1]]
      .x (d) -> d.x
      .y (d) -> d.y
      .addAll @data_nodes


  # Nodes methods
  # -------------------
  
  updateNodes: ->
    console.log 'updateNodes'

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
        d.state = 1
      else
        d.state = -1
    else
      d.state = 0

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
      

  # Drawing methods
  # -------------------

  # Tick Function
  onTick: =>
    # clear canvas
    @context.clearRect 0, 0, @viewport.width, @viewport.height
  
    @drawRelations()

    @drawNodes()

    if @parameters.showNodesLabel or @node_hovered
      @drawNodesLabels()

    # Draw quadtree
    ###
    if @quadtree
      @context.strokeStyle = '#ccc'
      @context.beginPath()
      @quadtree.visit (node, x0, y0, x1, y1) =>
        @context.rect x0, y0, x1-x0, y1-y0  
      @context.stroke()
      @context.closePath()
    ###


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
    @context.lineWidth = 1
    @context.strokeStyle = 'rgba(255,255,255,0.85)'
    @context.textAlign = 'center'
    @context.textBaseline = 'top'
    @data_nodes.forEach (d) =>
      # don't draw labels of weaken nodes
      if d.state > -1
        @context.fillStyle = d.fontColor
        @context.font      = '300 '+d.fontSize+'px Montserrat'
        @context.strokeText  d.name, d.x, d.y+d.size+1
        @context.fillText  d.name, d.x, d.y+d.size

  drawRelations: ->
    # make stroke color dynamic based on nodes state !!!
    @context.strokeStyle = '#ccc'
    @context.lineWidth = 1
    @context.beginPath()
    @data_relations_visibles.forEach (link) =>
      @context.moveTo link.source.x, link.source.y
      @context.lineTo link.target.x, link.target.y
    @context.stroke()
    @context.closePath()

  updateNodesColorValue: =>
    super()
    @data_nodes.forEach (d) =>
      @setNodeFill d
      @setNodeStroke d


  # Canvas Mouse Events
  # -------------------

  onCanvasEnter: =>
    @onCanvasMove()

  onCanvasMove: =>
    # get mouse point
    mouse = d3.mouse @canvas.node()
    @setQuadtree()
    node = @quadtree.find mouse[0], mouse[1]
    # check @node_active !!!
    #if @node_active
    #  return
    if @node_hovered and @node_hovered.id == node.id
      return
    @updateNodeHovered node

  onCanvasLeave: (e) =>
    @updateNodeHovered null

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
    # update canvas if force layout stoped
    if @force.alpha() < @force.alphaMin()
      @onTick()


module.exports = VisualizationCanvas