Handsontable            = require './../dist/handsontable.full.js'
VisualizationTableBase  = require './visualization-table-base.js'

class VisualizationTableNodes extends VisualizationTableBase

  el:               '.visualization-table-nodes'
  nodes_type:       null
  tableColHeaders:  ['', 'Node', 'Type', 'Description', 'Visible']

  constructor: (@collection) ->
    super @collection, 'node'
    # Override Table Options
    @table_options.colHeaders  = @tableColHeaders
    @table_options.columns     = @getTableColumns()

  onCollectionSync: =>
    super()
    @getNodeTypes()

  # Setup Handsontable columns options
  getTableColumns: =>
    return [
      { 
        data: '',
        readOnly: true,
        renderer: @rowDeleteRenderer
      },
      { 
        data: 'name' 
      },
      { 
        data: 'node_type',
        type: 'autocomplete',
        source: @nodes_type,
        strict: false
      },
      { 
        data: 'description',
        renderer: 'html'
      },
      { 
        data: 'visible', 
        type: 'checkbox',
        renderer: (instance, td, row, col, prop, value, cellProperties) =>
          # We keep checkbox render in order to toogle value with enter key
          Handsontable.renderers.CheckboxRenderer.apply(this, arguments)
          # Add visible icon link
          link = document.createElement('A');
          link.className = if value then 'icon-visible active' else 'icon-visible'
          link.innerHTML = link.title = 'Node Visibility'
          td.appendChild(link)
          # Toggle visibility value on click
          Handsontable.Dom.addEvent link, 'click', (e) =>
            e.preventDefault()
            @table.setDataAtCell(row, col, !value)
          return td
      },
    ]

  getNodeTypes: =>
    #console.log 'getNodeTypes'
    $.ajax {
      url: '/api/visualizations/'+$('body').data('id')+'/nodes/types.json'
      dataType: 'json'
      success: @onNodesTypesSucess
    }

  onNodesTypesSucess: (response) =>
    @nodes_type = response
    @setNodesTypeSource()
    @table_options.afterChange       = @onTableChange
    @setupTable()
    
  #!!! No de debería usar esta función. La sincronización entre tabla y canvas debe realizarse 
  #!!! a través de `collection`, no de eventes de la tabla
  onTableChange: (changes, source) =>
    if source != 'loadData'
      for change in changes
        if change[2] != change[3]
          @updateNode change
          
  updateNode: (change) =>
    console.log 'change', change, @table.getDataAtRowProp(change[0], 'id')
    index = change[0]
    key = change[1]
    value = change[3]
    model_id = @table.getDataAtRowProp(index, 'id')
    #!!! no puedo recoger el model de la collections por el index de la tabla (change[0])
    #!!! debo recoger el id del objeto de la tabla y a partir de ese id recoger el model de la collection
    model = @collection.get model_id
    console.log 'change model', model
    # Add new node_type to node_types array
    if key == 'node_type' && !_.contains(@nodes_type, value)
      @addNodeType value
    # Update node attribute
    #else
      #Backbone.trigger 'visualization.node.'+key, {value: value, node: model}
    obj = {}
    obj[ key ] = value
    model.save obj
    #console.log obj

  addNodeType: (type) ->
    @nodes_type.push type
    @setNodesTypeSource()

  # Set 'Node Type' column source in table_options
  setNodesTypeSource: ->
    @table_options.columns[2].source = @nodes_type


module.exports = VisualizationTableNodes
