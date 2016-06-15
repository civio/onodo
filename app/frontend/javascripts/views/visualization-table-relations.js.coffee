Handsontable             = require './../dist/handsontable.full.js'
VisualizationTableBase   = require './visualization-table-base.js'

class VisualizationTableRelations extends VisualizationTableBase

  el:               '.visualization-table-relations'
  relations_types:  null
  nodes:            null
  tableColHeaders:  ['', '', 'Source', 'Relationship', 'Target', 'Date', 'Direction', '<a class="add-custom-column" title="Create Custom Column" href="#"></a>']
  duplicate:        null
  columns:          {
    'delete'    : 0,
    'duplicate' : 1,
    'source'    : 2,
    'type'      : 3,
    'target'    : 4
  }

  constructor: (@model, @collection) ->
    super @model, @collection, 'relation'
    # Override Table Options
    @table_options.colHeaders  = @tableColHeaders
    @table_options.columns     = @getTableColumns()

  render: ->
    super()
    #console.log 'VisualizationTableRelations render'
    @getRelationsTypes()

  # Setup Handsontable columns options
  getTableColumns: =>
    return [
      { 
        data: '',
        readOnly: true,
        renderer: @rowDeleteRenderer
      },
      { 
        data: '',
        readOnly: true,
        renderer: @rowDuplicateRenderer
      },
      { 
        data: 'source_name'
        type: 'dropdown'
      },
      { 
        data: 'relation_type'
        type: 'autocomplete'
        source: @relations_types
        strict: false
      },
      { 
        data: 'target_name'
        type: 'dropdown'
      },
      { 
        data: 'at' 
        readOnly: true
        renderer: @rowDateRenderer
      },
      { 
        data: 'direction'
        type: 'checkbox'
        renderer: @rowDirectionRenderer
      },
      { 
        data: ''
        readOnly: true
      }
    ]

  setNodes: (_nodes) =>
    @nodes = _nodes
    # Update nodes dropdown source when nodes added or removed
    @nodes.on 'update', @updateNodes, @
    # Update source or target names and its dropdown
    @nodes.on 'change:name', (node, value) =>
      # Update source or target names
      @table_options.data.forEach (d,i) =>
        if d.source_id == node.id
          @table.setDataAtRowProp i, 'source_name', value
        if d.target_id == node.id
          @table.setDataAtRowProp i, 'target_name', value
      # Update nodes dropdown source when nodes change its name
      @updateNodes()
    , @
    @nodes.on 'remove', @removeRelationsWithNode, @

  updateNodes: =>
    @table_options.columns[ @columns.source ].source = @table_options.columns[ @columns.target ].source = @nodes.toJSON().map((d) -> return d.name).sort()
    #console.log 'table relations nodes sync', @table_options.columns[ @columns.source ].source
    # update table settings when needed
    if @table
      @table.updateSettings @table_options

  getRelationsTypes: =>
    #console.log 'getRelationsTypes'
    $.ajax {
      url: '/api/visualizations/'+@model.id+'/relations/types.json'
      dataType: 'json'
      success: @onRelationsTypesSucess
    }

  onRelationsTypesSucess: (response) =>
    @relations_types = response
    @setRelationsTypesSource()
    @setupTable()
    # Add on beforeKeyDown handler to change key ENTER behavior
    @table.addHook 'beforeKeyDown', @onBeforeKeyDown
    # Add Relation Btn Handler
    $('#visualization-add-relation-btn').click (e) =>
      e.preventDefault()
      @addRow()

  # Method called from parent class `VisualizationTableBase`
  createRow: (index) ->
    console.log 'createRow', index
    # We need to set `wait = true` to wait for the server before adding the new model to the collection
    # http://backbonejs.org/#Collection-create
    row_model = @collection.create {dataset_id: @model.get('dataset_id'), 'direction': false, wait: true}
    # We wait until model is synced in server to get its id
    @collection.once 'sync', () ->
      @table.setDataAtRowProp index, 'id', row_model.id
      # set duplicated values
      if @duplicate
        if @duplicate.get('source_name')
          @table.setDataAtRowProp index, 'source_name', @duplicate.get('source_name')
        if @duplicate.get('target_name')
          @table.setDataAtRowProp index, 'target_name', @duplicate.get('target_name')
        if @duplicate.get('relation_type')
          @table.setDataAtRowProp index, 'relation_type', @duplicate.get('relation_type')
        @table.setDataAtRowProp index, 'direction', @duplicate.get('direction')
        console.log 'now set duplicate values'
        @duplicate = null
      else
        @table.setDataAtRowProp index, 'direction', false
    , @

  # Method called from parent class `VisualizationTableBase`  
  updateCell: (change) =>
    index = change[0]
    key   = change[1]
    value = change[3]
    # Get model id in order to acced to model in Collection
    cell_id = @table.getDataAtRowProp(index, 'id')
    if cell_id
      cell_model = @collection.get cell_id
      # Add new node_type to nodes_types array
      if key == 'relation_type' && !_.contains(@relations_types, value)
        @addRelationsType value
      # Setup parameters to store in model
      obj = {}
      if key == 'source_name' or key == 'target_name'
        node = @nodes.filter((d) -> return d.get('name') == value)  # get node by node name
        console.log 'updateModel', node
        if node.length > 0
          if key == 'source_name'
            obj.source_id = node[0].id
            obj.source_name = node[0].get('name')
          else
            obj.target_id = node[0].id
            obj.target_name = node[0].get('name')
      # By now we store dates as 'at' date
      else if key == 'date'
        obj.at = value
      else
        obj[ key ] = value
      console.log 'updateModel', obj, cell_model
      # Save model with updated attributes in order to delegate in Collection trigger 'change' events
      cell_model.save obj, {patch: true}

  addRelationsType: (type) ->
    @relations_types.push type
    @setRelationsTypesSource()

  # Set 'Node Type' column source in table_options
  setRelationsTypesSource: ->
    @table_options.columns[ @columns.type ].source = @relations_types

  removeRelationsWithNode: (node) ->
    # descending loop though all relations
    for relation, i in @table_options.data by -1
      # if relation contains removed node in source or target we remove that relation
      if relation.source_id == node.id or relation.target_id == node.id
        @table.alter('remove_row', i, 1 )

  onBeforeKeyDown: (e) =>
    selected = @table.getSelected()
    # ENTER or SPACE keys
    if e.keyCode == 13 or e.keyCode == 32
      # In Delete column launch delete modal
      if selected[1] == @columns.delete and selected[3] == @columns.delete
        e.stopImmediatePropagation()
        e.preventDefault()
        @showDeleteModal selected[0]
      # In Duplicate column add duplicated row
      else if selected[1] == @columns.duplicate and selected[3] == @columns.duplicate
        e.stopImmediatePropagation()
        e.preventDefault()
        @duplicateRow selected[0]

  # Function to show modal with date edit form
  showDateModal: (index) =>
    console.log 'showDateModal', index
    $modal = $('#table-date-modal')
    # Load description edit form via ajax in modal
    $modal.find('.modal-body').load '/relations/'+@getIdAtRow(index)+'/edit/date/', () =>
      # Add on submit handler to save new description via model
      # $modal.find('.form-default').on 'submit', (e) =>
      #   e.preventDefault()
      #   @table.setDataAtRowProp index, 'description', $modal.find('#node_description').val()
      #   $modal.modal 'hide'
    # Show modal
    $modal.modal 'show'

  # Custom Renderer for date cells
  rowDateRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    # Add delete icon
    link = document.createElement('A')
    link.className = if value then 'icon-table' else 'icon-plus'
    link.innerHTML = link.title = 'Edit Date'
    Handsontable.Dom.empty(td)
    td.appendChild(link)
    # Add description modal on click event or keydown (enter or space)
    Handsontable.Dom.addEvent link, 'click', (e) =>
      e.preventDefault()
      @showDateModal row
    return td

  # Custom Renderer for direction cells
  rowDirectionRenderer: (instance, td, row, col, prop, value, cellProperties) =>
    # We keep checkbox render in order to toogle value with enter key
    Handsontable.renderers.CheckboxRenderer.apply(this, arguments)
    # Add visible icon link
    link = document.createElement('A');
    link.className = if value then 'icon-direction active' else 'icon-direction'
    link.innerHTML = link.title = 'Relationship Direction'
    td.appendChild(link)
    # Toggle visibility value on click
    Handsontable.Dom.addEvent link, 'click', (e) =>
      e.preventDefault()
      instance.setDataAtCell(row, col, !value)
    return td

module.exports = VisualizationTableRelations
