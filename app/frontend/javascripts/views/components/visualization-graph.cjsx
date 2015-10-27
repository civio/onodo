React = require 'react'

# Node Component
VisualizationGraphNodeComponent = React.createClass
  
  # Update Node when model change
  componentDidMount: ->
    @props.model.on 'change', (e) =>
      @forceUpdate()
    , @

  render: ->
    style = 
      display: if @props.model.get('visible') then 'list-item' else 'none'
    return <li style={style}>{@props.model.get('name')+' '+@props.model.get('description')}</li>

# Visualization Component
VisualizationGraphComponent = React.createClass

  render: ->
    return <ul>{ for item in @props.data 
      <VisualizationGraphNodeComponent key={item.id} model={item}/> }</ul>

module.exports = VisualizationGraphComponent