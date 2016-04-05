# Base Class for VisualizationTableNodes & VisualizationTableRelations
class VisualizationTableBase extends Backbone.View

  table:          null
  table_type:     null
  table_options:  null

  constructor: (@collection, table_type) ->
    super(@collection)
    @table_type = table_type
    console.log 'VisualizationTableBase', table_type
    @table_options =
      #minSpareRows: 1
      contextMenu: [ 'row_above', 'row_below', 'undo', 'redo' ] #[ 'row_above', 'row_below', 'remove_row', 'undo', 'redo' ]
      height: 360
      stretchH: 'all'
      columnSorting: true

  destroy: ->
    @undelegateEvents()
    @$el.removeData().unbind()
    @remove()
    Backbone.View.prototype.remove.call(@)

  initialize: (obj) ->
    console.log obj
    @collection.once 'sync', @onCollectionSync , @

  onCollectionSync: =>
    @table_options.data = @collection.toJSON()

  setupTable: ->
    @table_options.afterCreateRow    = @onTableCreateRow
    @table_options.afterChange       = @onTableChangeRow
    @table_options.beforeRemoveRow   = @onTableRemoveRow  # important to listen before remove to avoid index problems
    @table = new Handsontable @$el.get(0), @table_options

  onTableCreateRow: (index, amount) =>
    console.log 'onTableCreateRow', index, amount
    # Create a new model in collection
    @addModel index

  onTableChangeRow: (changes, source) =>
    if source != 'loadData'
      for change in changes
        if change[2] != change[3]
          console.log 'onTableChangeRow', changes, source
          # updateModel must be defined in inherit Classes
          @updateModel change

  onTableRemoveRow: (index, amount) =>
    # we need to get model id from row in order to remove the right model
    model_id = @getIdAtRow index
    model = @collection.get model_id
    if model  
      model.destroy()
  
  show: ->
    @$el.removeClass('hide')
    @table.render()

  hide: ->
    @$el.addClass('hide')

  render: =>
    return this

  getIdAtRow: (index) ->
    return @table.getDataAtRowProp(index, 'id')

  rowDeleteRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    # Add delete icon
    link = document.createElement('A');
    link.className = 'icon-trash'
    link.innerHTML = link.title = 'Delete ' + @table_type.charAt(0).toUpperCase() + @table_type.slice(1)
    Handsontable.Dom.empty(td)
    td.appendChild(link)
    # Delete row on click event
    Handsontable.Dom.addEvent link, 'click', (e) =>
      e.preventDefault()
      @table.alter('remove_row', row, 1 )
    return td

module.exports = VisualizationTableBase