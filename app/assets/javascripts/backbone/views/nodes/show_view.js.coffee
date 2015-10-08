Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.ShowView extends Backbone.View
  template: JST["backbone/templates/nodes/show"]

  render: ->
    @$el.html(@template(@model.toJSON() ))
    return this
