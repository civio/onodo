VisualizationGraphNode = React.createClass
  
  # Update Node when model change
  componentDidMount: ->
    @props.model.on 'change', (e) =>
      @forceUpdate()
    , @

  render: ->
    style = 
      display: if @props.model.get('visible') then 'list-item' else 'none'
    return <li style={style}>{@props.model.get('name')+' '+@props.model.get('description')}</li>

VisualizationGraph = React.createClass

  render: ->
    return <ul>{ for item in @props.data 
      <VisualizationGraphNode key={item.id} model={item}/> }</ul>

window.VisualizationGraph = VisualizationGraph