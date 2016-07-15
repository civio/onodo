Handsontable = require './../dist/handsontable.full.js'

# Base Class for VisualizationTableNodes & VisualizationTableRelations
class VisualizationTableBase extends Backbone.View

  table:             null
  table_type:        null
  table_options:     null
  table_height:      null
  table_offset_top:  null
  table_col_headers: null
  cell_types:
    'string':   'text'
    'number':   'numeric'
    'boolean':  'checkbox'
  #syncTable:        true  # allow activate/desactivate onTableChangeRow listener

  constructor: (@model, @collection, table_type) ->
    super(@model, @collection)
    @table_type = table_type
    #console.log 'VisualizationTableBase', table_type
    @table_options =
      #minSpareRows: 1
      contextMenu: [ 'row_above', 'row_below']  #, 'undo', 'redo' ]
      height: 360
      stretchH: 'all'
      columnSorting: true
      #filters: true
      #dropdownMenu: ['remove_col', '---------', 'filter_by_condition', 'filter_action_bar']
    @table_options.colHeaders  = @table_col_headers
    @table_options.columns     = @getTableColumns()

  destroy: ->
    @undelegateEvents()
    @$el.removeData().unbind()
    @remove()
    Backbone.View.prototype.remove.call(@)

  # Render base method override in Child Clases  
  render: =>
    # set table data
    @table_options.data = @collection.toJSON()

  setupTable: ->
    @table_options.afterCreateRow    = @onTableCreateRow
    @table_options.afterChange       = @onTableChangeRow
    @table_options.beforeRemoveRow   = @onTableRemoveRow  # important to listen before remove to avoid index problems
    @table = new Handsontable @$el.get(0), @table_options
    @resize()

  setupCustomFields: (custom_fields) => 
    if custom_fields
      custom_fields.forEach (custom_field) =>
        @table_col_headers.push     @getCustomFieldNameAsLabel(custom_field.name)
        obj =  { data: custom_field.name, type: @cell_types[custom_field.type] }
        if custom_field.readonly
          obj.readOnly = true
        @table_options.columns.push obj

  getCustomFieldNameAsLabel: (name) ->
    return name.replace(/_+/g, ' ').toLowerCase()

  getCustomFieldNameAsParam: (name) ->
    return name.replace(/\s+/g, '_').toLowerCase()

  getTableColumns: =>
    return []

  onTableCreateRow: (index, amount) =>
    # Create a new model in collection
    @createRow index

  onTableChangeRow: (changes, source) =>
    #console.log 'onTableChangeRow', changes, source
    #if @syncTable and source != 'loadData'
    if source != 'loadData' && source != 'external'
      #console.log 'onTableChangeRow', changes, source
      for change in changes
        if change[2] != change[3]
          #console.log 'onTableChangeRow', @table_type, changes, source
          # updateCell must be defined in inherit Classes
          @updateCell change

  onTableRemoveRow: (index, amount) =>
    # we need to get model id from row in order to remove the right model
    #console.log 'onTableRemoveRow', @table_type, index, amount
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
    #console.log 'resize table'
    @$el.height @table_height - (@$el.offset().top - @table_offset_top)

  addRow: ->
    @table.alter('insert_row', 0, 1 )

  # Duplicate row
  duplicateRow: (row) ->  
    # store duplicate model in duplicate variable in order to add row values when model sync in createRow
    row_id = @getIdAtRow row
    row_model = @collection.get(row_id)
    @duplicate = row_model
    # add new row after current one
    @table.alter('insert_row', row+1, 1 )
    #console.log 'duplicate row', row, row_model

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
      $modal.find('.btn-danger').off 'click'
    # Show confirmation modal
    $modal.modal 'show'

  # Add Custom Columns to table
  addCustomColumns: (columns, custom_fields_type, skip_sync) ->
    # get visualization model node_custom_fields or relation_custom_fields
    custom_fields = @model.get custom_fields_type
    # loop through each custom_field
    columns.forEach (column) =>
      # get custom field name as label (replacing _ symbol with black spaces)
      column_name_as_label = @getCustomFieldNameAsLabel(column.name)
      # if column is not in table_col_headers array add to it
      if @table_col_headers.indexOf(column_name_as_label) == -1
        # get custom field name as param (replacing black spaces with _)
        column_name_as_param = @getCustomFieldNameAsParam(column.name)
        # push column name in table_col_headers array
        @table_col_headers.push column_name_as_label
        # push new column data in columns array
        obj = { data: column_name_as_param }
        if column.readonly
          obj.readOnly = column.readonly
        @table_options.columns.push obj
        # update custom_fields in visualization model 
        obj = { name: column_name_as_param, type: column.type }
        if column.readonly
          obj.readonly = column.readonly
        custom_fields.push obj  
    # update colHeaders array
    @table_options.colHeaders = @table_col_headers
    # update table options
    if @table
      @table.updateSettings @table_options
    # (we use patch true to save only custom_fields attr instead of the whole Visualization model)
    unless skip_sync
      @model.save {custom_fields_type: custom_fields}, {patch: true}
    # trigger events for visualization configuration panel
    @model.trigger 'change:'+custom_fields_type

  # Custom Renderer for duplicate cells
  rowDuplicateRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    # Add duplicate icon
    link = document.createElement('A')
    link.className = 'icon-duplicate'
    link.innerHTML = link.title = 'Duplicate ' + @table_type.charAt(0).toUpperCase() + @table_type.slice(1)
    Handsontable.Dom.empty(td)
    td.appendChild(link)
    # Duplicate row on click event
    Handsontable.Dom.addEvent link, 'click', (e) =>
      e.preventDefault()
      @duplicateRow row
    return td

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