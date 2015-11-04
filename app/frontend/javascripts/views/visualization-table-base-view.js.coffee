# Base Class for VisualizationTableNodesView & VisualizationTableRelationsView
class VisualizationTableBaseView extends Backbone.View

  table         = null
  table_options = null

  constructor: (@collection) ->
    super(@collection)
    @table_options =
      contextMenu: [ 'row_below', 'remove_row', 'undo', 'redo' ] #[ 'row_above', 'row_below', 'remove_row', 'undo', 'redo' ]
      height: 360
      stretchH: 'all'
      columnSorting: true

  destroy: ->
    @undelegateEvents()
    @$el.removeData().unbind()
    @remove()
    Backbone.View.prototype.remove.call(@)

  initialize: ->
    @collection.once 'sync', @onCollectionSync , @

  onCollectionSync: =>
    @table_options.data = @collection.toJSON()

  setupTable: ->
    @table_options.afterRemoveRow    = @onTableRemoveRow
    @table_options.afterCreateRow    = @onTableCreateRow
    @table = new Handsontable @$el.get(0), @table_options

  onTableRemoveRow: (index, amount) =>
    console.log index, amount
    while amount > 0
      model = @collection.at index
      model.destroy()
      amount--
     
  onTableCreateRow: (index, amount) =>
    console.log index, amount
    model = @collection.create {}
    console.log model, model.get('id')
  
  show: ->
    @$el.removeClass('hide')
    @table.render()

  hide: ->
    @$el.addClass('hide')

  render: =>
    return this

module.exports = VisualizationTableBaseView