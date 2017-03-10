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


  # Tick Function
  onTick: =>
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
    @context.fillStyle = 'steelblue'
    @context.beginPath()
    @data_nodes.forEach (node) =>
      console.log node 
      @context.moveTo node.x, node.y
      @context.arc node.x, node.y, 8, 0, 2*Math.PI, true
    @context.fill()
    @context.closePath()

    # Draw Labels
    @context.fillStyle = '#676767'
    @context.font = '12px Montserrat'
    @context.textAlign = 'center'
    @data_nodes.forEach (node) =>
      @context.fillText node.name, node.x, node.y+15


module.exports = VisualizationCanvas