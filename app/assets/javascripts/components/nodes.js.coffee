{ div, h2, table, thead, tbody, tr, th } = React.DOM

Nodes = React.createClass

  # Display name used for debugging
  displayName: 'Nodes'

  getInitialState: ->
    nodes: @props.data
  
  getDefaultProps: ->
    nodes: []

  addNode: (node) ->
    nodes = React.addons.update(@state.nodes, { $push: [node] })
    @setState nodes: nodes

  updateNode: (node, data) ->
    index = @state.nodes.indexOf node
    nodes = React.addons.update( @state.nodes, { $splice: [[index, 1, data]] })
    @replaceState nodes: nodes

  deleteNode: (node) ->
    index = @state.nodes.indexOf node
    nodes = React.addons.update( @state.nodes, { $splice: [[index, 1]] })
    @replaceState nodes: nodes

  render: ->
    div { className: "nodes row" },
      table { className: "table" },
        thead {},
          tr {},
            th {},
            th {}, "Name"
            th {}, "Description"
        tbody {},
          for node in @state.nodes
            React.createElement Node, key: node.id, node: node, handleEditNode: @updateNode, handleDeleteNode: @deleteNode
    #React.createElement NodeForm, handleNewNode: @addNode