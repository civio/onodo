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
      contextMenu: null, # [ 'row_below', 'remove_row', 'undo', 'redo' ] #[ 'row_above', 'row_below', 'remove_row', 'undo', 'redo' ]
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
    @table_options.afterRemoveRow    = @onTableRemoveRow
    @table_options.afterCreateRow    = @onTableCreateRow
    @table = new Handsontable @$el.get(0), @table_options

  onTableRemoveRow: (index, amount) =>
    while amount > 0
      model = @collection.at index
      model.destroy()
      amount--
     
  onTableCreateRow: (index, amount) =>
    console.log 'onTableCreateRow'
    console.log index, amount
    model = @collection.create {dataset_id: $('body').data('id'), visible: true}
    #console.log model, model.get('id'), model.attributes.id
    #@table.setDataAtCell index, 0, model.id
    #Backbone.trigger 'visualization.'+@table_type+'.create', {id: model.get('id')}
  
  show: ->
    @$el.removeClass('hide')
    @table.render()

  hide: ->
    @$el.addClass('hide')

  render: =>
    return this

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