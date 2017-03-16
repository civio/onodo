d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvas extends VisualizationCanvasBase

  context:      null
  quadtree:     null
  node_hovered: null


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


  # Canvas Mouse Events
  # -------------------

  onCanvasEnter: =>
    console.log 'onCanvasIn'
    @onCanvasMove()

  onCanvasMove: =>
    # get mouse point
    mouse = d3.mouse @canvas.node()
    @setQuadtree()
    node = @quadtree.find mouse[0], mouse[1]
    if @node_hovered and @node_hovered.id == node.id
      return
    @data_nodes.forEach (d) -> d.disabled = true 
    @node_hovered = node
    @areNodesRelated(d, o)
    @node_hovered.disabled = false
    @updateNodesColorValue()
    # update canvas if force layout stoped
    if @force.alpha() < @force.alphaMin()
      @onTick()

  onCanvasLeave: (e) =>
    console.log 'onCanvasOut'
    @node_hovered = null
    @data_nodes.forEach (d) -> d.disabled = false 
    @updateNodesColorValue()
    # update canvas if force layout stoped
    if @force.alpha() < @force.alphaMin()
      @onTick()


  updateNodes: ->
    # Set nodes size
    @setNodesSize()

    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)
    
    # JOIN new data with old elements
    @nodes = @container.selectAll('.node').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes.exit().remove()

    # UPDATE old elements present in new data
    @nodes.call @setNode

    # ENTER new elements present in new data.
    @nodes.enter().append('circle')
      .attr 'class', 'node'
      .call @setNode

    @nodes = @container.selectAll('.node')

    console.table @nodes


  setNode: (node) =>
    node
      #.attr 'id',       (d) -> return 'node-'+d.id
      #.attr 'disabled',   (d) -> return d.disabled
      #.attr  'r',       (d) -> return d.size
      #.attr  'cx',      @viewport.center.x
      #.attr  'cy',      @viewport.center.y
      .attr 'font-size',  @getNodeFontSize
      .attr 'font-color', @getNodeFontColor
      .attr 'fill',       @getNodeFill
      .attr 'stroke',     @getNodeStroke

  getNodeFontSize: (d) =>
    if @parameters.nodesSize != 1
      return 12
    else
      return [11,12,13,15][@scale_labels_size(d[@parameters.nodesSizeColumn])]

  getNodeFontColor: (d) =>
    if @parameters.nodesSize != 1
      return '#404040'
    else
      return ['#676767','#5a5a5a','#4d4d4d','#404040'][@scale_labels_size(d[@parameters.nodesSizeColumn])]

  # Tick Function
  onTick: =>
    #console.log 'ontick', @nodes
    # Update nodes & labels position
    #@nodes
    #  .attr 'cx', (d) -> return d.x
    #  .attr 'cy', (d) -> return d.y

    # clear canvas
    @context.clearRect 0, 0, @viewport.width, @viewport.height
    #@contextDump.clearRect 0, 0, @viewport.width, @viewport.height

    @context.textAlign = 'center'

    # Draw relations paths
    @context.strokeStyle = '#ccc';
    @context.beginPath();
    @data_relations_visibles.forEach (link) =>
      @context.moveTo link.source.x, link.source.y
      @context.lineTo link.target.x, link.target.y
    @context.stroke()
    @context.closePath()

    # Draw nodes
    @nodes.each (d, i, n) =>
      node = d3.select(n[i])
      # set styles
      @context.fillStyle = node.attr('fill')
      @context.strokeStyle = node.attr('stroke')
      # draw node
      @context.beginPath()
      @context.moveTo d.x, d.y
      @context.arc d.x, d.y, d.size, 0, 2*Math.PI, true
      @context.fill()
      @context.stroke()
      @context.closePath()

    # Draw Labels
    if @parameters.showNodesLabel or @node_hovered
      @nodes.each (d, i, n) =>
        if !d.disabled
          node = d3.select(n[i])
          @context.fillStyle = node.attr('font-color')
          @context.font      = node.attr('font-size')+'px Montserrat'
          @context.fillText  d.name, d.x, d.y+d.size+13


    # getNodeLabelClass: (d) =>
    # #console.log 'getNodeLabelClass', @parameters.nodesSize 
    # str = 'node-label'
    # if !@parameters.showNodesLabel
    #   str += ' hide'
    # if @parameters.showNodesLabelComplete 
    #   str += ' complete'
    # if d.disabled
    #   str += ' disabled'
    # if @parameters.nodesSize == 1
    #   str += ' size-'+@scale_labels_size(d[@parameters.nodesSizeColumn])
    # return str


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


  updateNodesColorValue: =>
    super()
    @nodes
      .attr 'fill',   @getNodeFill
      .attr 'stroke', @getNodeStroke

module.exports = VisualizationCanvas