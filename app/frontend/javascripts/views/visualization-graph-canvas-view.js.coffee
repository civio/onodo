d3 = require 'd3'

class VisualizationGraphCanvasView extends Backbone.View

  NODES_SIZE: 8

  svg:        null
  container:  null
  color:      null
  data:       null
  force:      null
  nodes:      null
  nodes_symbol: null
  links:      null
  labels:     null
  linkedByIndex: {}
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
    drag:
      x: 0
      y: 0
    scale: 1

  initialize: (options) ->

    console.log 'initialize canvas'

    @data = options.data

    # Setup linkedByIndex object
    @data.relations.forEach (d) =>
      @linkedByIndex[d.source+','+d.target] = true

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x  = @viewport.width*0.5
    @viewport.center.y  = @viewport.height*0.5

    # Setup color scale
    @color = d3.scale.category20()

    # Setup force
    @force = d3.layout.force()
      .charge(-120)
      .linkDistance(90)
      #.linkStrength(2)
      .size([@viewport.width, @viewport.height])

    # Setup SVG
    @svg = d3.select( @$el.get(0) )
      .append('svg:svg')
        .attr('width',  @viewport.width)
        .attr('height', @viewport.height)
        .call(d3.behavior.drag()
          .on('drag',       @onCanvasDrag)
          .on('dragstart',  @onCanvasDragStart)
          .on('dragend',    @onCanvasDragEnd))

    @container = @svg.append('g')

    @rescale()  # Translate svg

  render: ->

    console.log 'render canvas' 
  
    @force
      .nodes(@data.nodes)
      .links(@data.relations)
      .start();

    # Setup Links
    @links = @container.selectAll('.link')
      .data(@data.relations)
    .enter().append('line')
      .attr('class', 'link')

    # Setup Nodes
    @nodes = @container.selectAll('.node')
      .data(@data.nodes)
    .enter().append('g')
      .attr('class', 'node')
      .call(@force.drag)
      .on('mouseover',  @onNodeOver)
      .on('mouseout',   @onNodeOut)
      .on('click',      @onNodeClick)

    # Setup Nodes Symbol    
    @nodes_symbol = @nodes.append('circle')
      .attr('class', 'node-symbol')
      .attr('r', @NODES_SIZE)
      .style('fill', (d) => return @color(d.node_type))
    
    # Setup Nodes Text
    @labels = @container.selectAll('.text')
      .data(@data.nodes)
    .enter().append('text')
      .attr('class', 'label')
      .attr('dx', @NODES_SIZE+6)
      .attr('dy', '.35em')
      .text((d) -> return d.name)

    # Setup Force Layout tick
    @force.on 'tick', @onTick

    @setupEvents()

  setupEvents: ->
    # Subscribe Config Panel Events
    Backbone.on 'config.param.change', @updateForceParameters, @
    # Subscribe Navigation Events
    Backbone.on 'navigation.zoomin', @onZoomIn, @
    Backbone.on 'navigation.zoomout', @onZoomOut, @
    Backbone.on 'navigation.fullscreen', @onFullscreen, @

  updateForceParameters: (e) ->
    @force.stop()
    if e.name == 'linkDistance'
      @force.linkDistance e.value
    else if e.name == 'linkStrength'
      @force.linkStrength e.value
    else if e.name == 'friction'
      @force.friction e.value
    else if e.name == 'charge'
      @force.charge e.value
    else if e.name == 'theta'
      @force.theta e.value
    else if e.name == 'gravity'
      @force.gravity e.value
    @force.start()

  onZoomIn: ->
    console.log 'zoomin'
    
  onZoomOut: ->
    console.log 'zoomout'

  onFullscreen: ->
    console.log 'fullscreen'

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
    if @viewport.drag.x == d.x and @viewport.drag.y == d.y
      return  # Skip if has no translation
    # fix the node position when the node is dragged
    # d.fixed = true;

  onNodeOver: (d) =>
    @nodes_symbol.attr('class', (o) =>
      return if @isConnected(d, o) then 'node-symbol highlighted' else 'node-symbol weaken')
    @labels.attr('class', (o) =>
      return if @isConnected(d, o) then 'label highlighted' else 'label weaken')
    @links.attr('class', (o) =>
      return if o.source.index == d.index || o.target.index == d.index then 'link highlighted' else 'link weaken')

  onNodeOut: (d) =>
    @nodes_symbol.attr('class', 'node-symbol')
    @labels.attr('class', 'label')
    @links.attr('class', 'link')

  onNodeClick: (d) =>

  # Tick Function
  onTick: =>
    @links.attr('x1', (d) -> return d.source.x)
        .attr('y1', (d) -> return d.source.y)
        .attr('x2', (d) -> return d.target.x)
        .attr('y2', (d) -> return d.target.y)
    @nodes.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')
    @labels.attr('transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')')  

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
    @container.attr 'transform', 'translate(' + (@viewport.origin.x+@viewport.x) + ',' + (@viewport.origin.y+@viewport.y) + ')scale(' + @viewport.scale + ')'

  # Utils Functions
  isConnected: (a, b) ->
    return @linkedByIndex[a.index + ',' + b.index] || @linkedByIndex[b.index + ',' + a.index] || a.index == b.index

  hasConnections: (a) ->
    for property in @linkedByIndex
      s = property.split(',')
      if (s[0] == a.index || s[1] == a.index) and @linkedByIndex[property]       
        return true;
    return false

module.exports = VisualizationGraphCanvasView