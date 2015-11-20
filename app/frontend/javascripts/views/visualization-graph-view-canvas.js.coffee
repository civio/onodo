d3            = require 'd3'

class VisualizationGraphViewCanvas extends Backbone.View
  #propTypes:
  #  data: React.PropTypes.arrayOf(React.PropTypes.number)

  svg:      null
  color:    d3.scale.category20()
  data:     null
  force:    null

  initialize: (options) ->
    console.log 'initialize canvas'
    @data = options.data
    # Setup force
    @force = d3.layout.force()
      .charge(-120)
      .linkDistance(60)
      #.linkStrength(2)
      .size([@$el.width(), @$el.height()])
    # Setup SVG
    @svg = d3.select( @$el.get(0) )
      .append('svg:svg')
        .attr('width', @$el.width())
        .attr('height', @$el.height())

    #@collection.nodes.on 'change', (e) =>
    #@collection.relations.on 'change', (e) =>

  render: ->

    console.log 'render canvas' 
    
    # setup nodes & relations as arrays with Models attributes
    #@data.nodes      = @collection.nodes.models.map((d) -> return d.attributes)
    #@data.relations  = @collection.relations.models.map((d) -> return d.attributes)

    # Fix relations source & target index (based on 1 instead of 0)
    #@data.relations.forEach (d) ->
    #  d.source = d.source_id-1
    #  d.target = d.target_id-1

    @force
      .nodes(@data.nodes)
      .links(@data.relations)
      .start();

    # Setup Links
    link = @svg.selectAll('.link')
      .data(@data.relations)
    .enter().append('line')
      .attr('class', 'link');

    # Setup Nodes
    nodes = @svg.selectAll('.node')
      .data(@data.nodes)
    .enter().append('circle')
      .attr('class', 'node')
      .attr('r', 6)
      .attr('cx', @$el.width()*0.5)
      #.attr('cx', (d,i) -> return 20+30*i )
      .attr('cy', @$el.height()*0.5)
      #.style('visibility', (d) -> return if d.visible then 'visible' else 'hidden') 
      .style('fill', (d) => return @color(d.node_type))
      .call(@force.drag)

    # Setup Force Layout tick
    @force.on 'tick', () ->
      link.attr('x1', (d) -> return d.source.x)
          .attr('y1', (d) -> return d.source.y)
          .attr('x2', (d) -> return d.target.x)
          .attr('y2', (d) -> return d.target.y)
      nodes.attr('cx', (d) -> return d.x)
          .attr('cy', (d) -> return d.y)

    # svg.selectAll('.dot')
    #   .data( data )
    # .enter().append('g')
    #   .attr('class', (d) -> return 'dot dot-'+d.id)
    #   .attr('transform', (d,i) -> return 'translate(20,'+(20+40*i)+')')
    #   .style('visibility', (d) -> return if d.visible then 'visible' else 'hidden') 

    # svg.selectAll('.dot')
    #   .append('circle')
    #   .attr('r', 10)
    #   .attr('fill','gray')

    # svg.selectAll('.dot')
    #   .append('text')
    #   .attr('fill','gray')
    #   .attr('dx', 18)
    #   .attr('dy', 5)
    #   .text((d) -> d.name)

    #We ask D3 for the underlying fake node and then render it as React elements.
    #return svg.node().toReact()

module.exports = VisualizationGraphViewCanvas