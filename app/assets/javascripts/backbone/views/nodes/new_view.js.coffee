Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.NewView extends Backbone.View
  template: JST["backbone/templates/nodes/new"]

  events:
    "submit #new-node": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (node) =>
        @model = node
        window.location.hash = "/#{@model.id}"

      error: (node, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    @$el.html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
