Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.IndexView extends Backbone.View

  template: JST["backbone/templates/nodes/index"]

  initialize: ->
    console.log 'initialize view'
    #@collection.bind('reset', @addAll)
    @collection.on('sync', @render , @)

  addAll: () =>
    console.log 'initialize view all add'
    @collection.each(@addOne)

  addOne: (node) =>
    view = new Onodo.Views.Nodes.NodeView({model : node})
    @$("tbody").append(view.render().el)

  render: =>

    hot = new Handsontable( document.getElementById('visualization-table-nodes'), {
      data: @collection.toJSON(),
      contextMenu: true,
      # columns: [
      #   @attr('name'),
      #   @attr('description'),
      #   @attr('visible')
      # ],
      colHeaders: ['', 'Name', 'Description', '', '']
    })

    #@$el.html(@template(nodes: @collection ))
    #@addAll()

    return this
