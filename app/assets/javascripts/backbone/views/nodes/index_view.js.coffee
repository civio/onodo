Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.IndexView extends Backbone.View

  template: JST["backbone/templates/nodes/index"]

  _this = @

  initialize: ->
    console.log 'initialize view'
    _this.collection = @collection
    #@collection.bind('reset', @addAll)
    @collection.once('sync', @render , @)

  addAll: () =>
    console.log 'initialize view all add'
    @collection.each(@addOne)

  addOne: (node) =>
    view = new Onodo.Views.Nodes.NodeView({model : node})
    @$("tbody").append(view.render().el)

  onTableChange: (changes, source) ->
    console.log 'change', source
    if source != 'loadData'
      for change in changes
        console.log 'change', change
        obj = {}
        obj[ change[1] ] = change[3]
        model = _this.collection.at change[0]
        model.save obj
     
  render: =>

    hot = new Handsontable( document.getElementById('visualization-table-nodes'), {
      data: @collection.toJSON(),
      contextMenu: true,
      height: 360,
      stretchH: 'all',
      tableClassName: ['table', 'table-hover', 'table-striped'],
      #columnSorting: true,
      # columns: [
      #   @attr('name'),
      #   @attr('description'),
      #   @attr('visible')
      # ],
      colHeaders: ['', 'Name', 'Description', '', ''],
      afterChange: @onTableChange
    })

    #@$el.html(@template(nodes: @collection ))
    #@addAll()

    return this
