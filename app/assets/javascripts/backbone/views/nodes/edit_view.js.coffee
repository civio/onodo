Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.EditView extends Backbone.View
  template: JST["backbone/templates/nodes/edit"]

  events:
    "submit #edit-node": "update"

  update: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success: (node) =>
        @model = node
        window.location.hash = "/#{@model.id}"
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
