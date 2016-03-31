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
    #console.log @table_options.data
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
        data: 'node_type'
        type: 'autocomplete'
        strict: false
      },
      { 
        data: 'description' 
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

  getNodeTypes: ->
    console.log 'getNodeTypes'
    $.ajax {
      url: '/api/nodes/types.json'
      dataType: 'json'
      success: @onNodesTypesSucess
    }

  onNodesTypesSucess: (response) =>
    @nodes_type = response
    @table_options.columns[3].source = @nodes_type
    @table_options.afterChange       = @onTableChange
    @setupTable()
    
  onTableChange: (changes, source) =>
    if source != 'loadData'
      for change in changes
        if change[2] != change[3]
          @updateNode change
          
  updateNode: (change) =>
    console.log 'change', change
    key = change[1]
    value = change[3]
    model = @collection.at change[0]
    if key == 'visible' || key == 'name' || key == 'description'
      Backbone.trigger 'visualization.node.'+key, {value: value, node: model}
    else if key == 'node_type' && !_.contains(@nodes_type, value)
      @addNodeType value
    obj = {}
    obj[ key ] = value
    model.save obj
    #console.log obj

  addNodeType: (type) ->
    @nodes_type.push type
    @table_options.columns[3].source = @nodes_type


module.exports = VisualizationTableNodes
