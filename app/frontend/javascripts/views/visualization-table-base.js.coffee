# Base Class for VisualizationTableNodes & VisualizationTableRelations
class VisualizationTableBase extends Backbone.View

  table:            null
  table_type:       null
  table_options:    null
  table_height:     null
  table_offset_top: null

  constructor: (@collection, table_type) ->
    super(@collection)
    @table_type = table_type
    console.log 'VisualizationTableBase', table_type
    @table_options =
      #minSpareRows: 1
      contextMenu: null #[ 'row_above', 'row_below', 'undo', 'redo' ]
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
    @resize()

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
    @resize()
    @table.render()

  hide: ->
    @$el.addClass('hide')

  setSize: (tableHeight, tableOffsetTop) =>
    @table_height     = tableHeight
    @table_offset_top = tableOffsetTop
    @resize()

  resize: =>
    console.log 'resize table'
    @$el.height @table_height - (@$el.offset().top - @table_offset_top)

  render: =>
    return this

  addRow: ->
    @table.alter('insert_row', 0, 1 )

  getIdAtRow: (index) ->
    return @table.getDataAtRowProp(index, 'id')

  # Function to show delete modal
  showDeleteModal: (index) =>
    $modal = $('#delete-'+@table_type+'-modal')
    # Add click event handler on confirmation btn to delete current row
    $modal.find('.btn-danger').on 'click', (e) =>
      $modal.modal 'hide'
      @table.alter('remove_row', index, 1 )
    # Remove on click event when hide modal
    $modal.on 'hidden.bs.modal', (e) ->
      $modal.find('btn-danger').off 'click'
    # Show confirmation modal
    $modal.modal 'show'

  # Custom Renderer for delete cells
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
      @showDeleteModal row
    return td

module.exports = VisualizationTableBase