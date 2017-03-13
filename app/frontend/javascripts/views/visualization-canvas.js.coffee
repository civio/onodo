d3 = require '../dist/d3'
VisualizationCanvasBase = require './visualization-canvas-base.js'

class VisualizationCanvas extends VisualizationCanvasBase

  context: null

  setupCanvas: ->
    # Setup canvas
    @canvas = d3.select(@el).append('canvas')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      #.call canvasDrag
    # Setup canvas context
    @context = @canvas.node().getContext('2d')

  setupContainers: ->
    # Setup a custom element container that will not be attached to the DOM, to which we can bind the data
    customElement = document.createElement('custom')
    @container    = d3.select(customElement)

  updateNodes: ->
    # Set nodes size
    @setNodesSize()

    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes = @container.selectAll('.node').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes.exit().remove()

    # UPDATE old elements present in new data
    @nodes
      #.attr 'id',       (d) -> return 'node-'+d.id
      .attr 'class', 'node'
      .attr 'disabled',   (d) -> return d.disabled
      # update node size
      #.attr  'r',       (d) -> return d.size
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .attr 'fill',     @getNodeFill
      .attr 'stroke',   @getNodeStroke

    # ENTER new elements present in new data.
    @nodes.enter().append('circle')
      #.attr  'id',      (d) -> return 'node-'+d.id
      .attr 'class', 'node'
      .attr 'disabled',   (d) -> return d.disabled
      # update node size
      #.attr  'r',       (d) -> return d.size
      # set position at viewport center
      #.attr  'cx',      @viewport.center.x
      #.attr  'cy',      @viewport.center.y
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .attr 'fill',     @getNodeFill
      .attr 'stroke',   @getNodeStroke
      #.on   'mouseover',  @onNodeOver
      #.on   'mouseout',   @onNodeOut
      #.on   'click',      @onNodeClick
      #.on   'dblclick',   @onNodeDoubleClick
      #.call @forceDrag

    @nodes = @container.selectAll('.node')


  # Tick Function
  onTick: =>
    #console.log 'ontick', @nodes
    # Update nodes & labels position
    #@nodes
    #  .attr 'cx', (d) -> return d.x
    #  .attr 'cy', (d) -> return d.y

    # clear canvas
    @context.clearRect 0, 0, @viewport.width, @viewport.height

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
      #console.log d, node
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
    if @parameters.showNodesLabel
      @context.fillStyle = '#676767'
      @context.font = '12px Montserrat'
      @context.textAlign = 'center'
      @data_nodes.forEach (d) =>
        @context.fillText d.name, d.x, d.y+d.size


module.exports = VisualizationCanvas