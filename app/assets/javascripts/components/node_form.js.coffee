{ div, form, input, button, h4 } = React.DOM

NodeForm = React.createClass

  # Display name used for debugging
  displayName: 'NodeForm'

  getInitialState: ->
    name: ''
    description: ''

  handleChangeName: (e) ->
    @setState "name" : e.target.value

  handleChangeDescription: (e) ->
    @setState "description" : e.target.value

  handleSubmit: (e) ->
    e.preventDefault()
    $.post '', { node: @state }, (data) =>
        @props.handleNewNode data
        @setState @getInitialState()
      , 'JSON'

  render: ->
    div { 
      className: "modal fade",
      id: "node-add-modal",
      tabindex: "-1",
      role: "dialog",
      "aria-labelledby": "node-add-modal",
    },
      div { className: "modal-dialog" },
        div { className: "modal-content" },
          div { className: "modal-header" },
            button {
              type: "button",
              className: "close",
              "data-dismiss": "modal",
              "aria-label": "Close"
            }, "&times;"
            h4 { className: "modal-title" }, "Add Node"
          div { className: "modal-body" },
            form { className: "form-inline" },
              div { className: "form-group" }
                input {
                  type: "text",
                  className: "form-control",
                  name: "name",
                  placeholder: "Name",
                  value: @state.name,
                  onChange: @handleChangeName
                }
              div { className: "form-group" }
                input {
                  type: "text",
                  className: "form-control",
                  name: "description",
                  placeholder: "Description",
                  value: @state.description,
                  onChange: @handleChangeDescription
                }
              button {
                type: "submit",
                className: "btn btn-default",
                onClick: @handleSubmit
              }, "Create Node"