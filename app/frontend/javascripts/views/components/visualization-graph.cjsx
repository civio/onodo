d3            = require 'd3'
React         = require 'react'
ReactFauxDOM  = require 'react-faux-dom'

#ReactFauxDOM Example 
VisualizationGraphD3Component = React.createClass
  #propTypes:
  #  data: React.PropTypes.arrayOf(React.PropTypes.number)

  # Update Node when model change
  componentDidMount: ->
    @props.collection.on 'change', (e) =>
      @forceUpdate()
    , @

  render: ->
    # setup a data array with Models attributes
    data = @props.collection.models.map( (d) -> return d.attributes )

    # This is where we create the faux DOM node and give it to D3.
    svg = d3.select( ReactFauxDOM.createElement('svg') )
      .attr('width', 600)
      .attr('height', 400)

    svg.selectAll('.dot')
      .data( data )
    .enter().append('g')
      .attr('class', (d) -> return 'dot dot-'+d.id)
      .attr('transform', (d,i) -> return 'translate(20,'+(20+40*i)+')')
      .style('visibility', (d) -> return if d.visible then 'visible' else 'hidden') 

    svg.selectAll('.dot')
      .append('circle')
      .attr('r', 10)
      .attr('fill','gray')

    svg.selectAll('.dot')
      .append('text')
      .attr('fill','gray')
      .attr('dx', 18)
      .attr('dy', 5)
      .text((d) -> d.name+' '+d.description)

    #We ask D3 for the underlying fake node and then render it as React elements.
    return svg.node().toReact()

module.exports = VisualizationGraphD3Component