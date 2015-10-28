Handsontable                = require './../dist/handsontable.full.js'
VisualizationTableBaseView  = require './visualization-table-base-view.js'

class VisualizationTableNodesView extends VisualizationTableBaseView

  nodes_type      = null
  tableColHeaders = ['', 'Name', 'Description', 'Type', 'Visible']
  tableColumns    = [
    { 
      data: 'id'
      type: 'numeric' 
    },
    { 
      data: 'name' 
    },
    { 
      data: 'description' 
    },
    { 
      data: 'node_type'
      type: 'autocomplete'
      strict: false
    },
    { 
      data: 'visible', 
      type: 'checkbox' 
    },
  ]

  constructor: (@collection) ->
    super(@collection)
    # Override Table Options
    @table_options.colHeaders  = tableColHeaders
    @table_options.columns     = tableColumns

  onCollectionSync: =>
    super()
    console.log @table_options.data
    @getNodeTypes()

  getNodeTypes: ->
    console.log 'getNodeTypes'
    $.ajax {
      url: '/api/nodes-types.json'
      dataType: 'json'
      success: @onNodesTypesSucess
    }

  onNodesTypesSucess: (response) =>
    nodes_type = response
    @table_options.columns[3].source = nodes_type
    @table_options.afterChange       = @onTableChange
    @table_options.afterRemoveRow    = @onTableRemoveRow
    @table_options.afterCreateRow    = @onTableCreateRow
    # Setup HandsOnTable
    table = new Handsontable @$el.get(0), @table_options
    
  onTableChange: (changes, source) =>
    if source != 'loadData'
      for change in changes
        if change[2] != change[3]
          console.log 'change', change
          key = change[1]
          value = change[3]
          if key == 'node_type' && !_.contains(nodes_type, value)
            @addNodeType value
          obj = {}
          obj[ key ] = value
          model = @collection.at change[0]
          model.save obj

  addNodeType: (type) ->
    nodes_type.push type
    @table_options.columns[3].source = nodes_type

module.exports = VisualizationTableNodesView
