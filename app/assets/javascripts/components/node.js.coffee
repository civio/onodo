{ tr, td, a, i, input } = React.DOM

Node = React.createClass

  getInitialState: ->
    edit: false

  handleDelete: (e) ->
    e.preventDefault()
    $.ajax
      method: 'DELETE'
      url: "/nodes/#{ @props.node.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteNode @props.node

  handleEdit: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  handleUpdate: (e) ->
    e.preventDefault()
    data =
      name: React.findDOMNode(@refs.name).value
      description: React.findDOMNode(@refs.description).value
    # jQuery doesn't have a $.put shortcut method either
    $.ajax
      method: 'PUT'
      url: "/nodes/#{ @props.node.id }"
      dataType: 'JSON'
      data:
        node: data
      success: (data) =>
        @setState edit: false
        @props.handleEditNode @props.node, data

  # Non-edit node row
  nodeRow: ->
    tr {},
      th {},
        div { className: "btn-group", role: "group" },
          a { 
            className: "btn btn-success edit-node", 
            href: '#',
            onClick: @handleEdit
          },
            i { className: "glyphicon glyphicon-pencil" },
          a { 
            className: "btn btn-danger remove-node", 
            href: '#',
            onClick: @handleDelete
          },
            i { className: "glyphicon glyphicon-remove" }
      td {}, @props.node.name
      td {}, @props.node.description

  # Edit node row
  nodeForm: ->
    tr {},
      th {},
        div { className: "btn-group", role: "group" },
          a { 
            className: "btn btn-success edit-node", 
            href: '#',
            onClick: @handleUpdate
          }, 'Update'
          a { 
            className: "btn btn-danger remove-node", 
            href: '#',
            onClick: @handleEdit
          }, 'Cancel'
      td {},
        input {
          className: 'form-control',
          type: 'text',
          ref: 'name',
          defaultValue: @props.node.name
        }   
      td {},
        input {
          className: 'form-control',
          type: 'text',
          ref: 'description',
          defaultValue: @props.node.description
        }

  render: ->
    if @state.edit
      @nodeForm()
    else
      @nodeRow()
