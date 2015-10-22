NodeGraph = React.createClass

  handleClick: ->
    alert 'Hello!'

  render: ->
    return <a href="#" onClick={this.handleClick}>A Node!</a>