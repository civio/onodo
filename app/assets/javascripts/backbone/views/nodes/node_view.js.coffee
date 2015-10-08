Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.NodeView extends Backbone.View
  template: JST["backbone/templates/nodes/node"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
