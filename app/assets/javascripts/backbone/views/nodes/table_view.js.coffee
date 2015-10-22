Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.TableView extends Backbone.View

  #template: JST["backbone/templates/nodes/index"]

  table         = null
  nodes_type    = null
  table_options = 
    contextMenu: [ 'row_below', 'remove_row', 'undo', 'redo' ] #[ 'row_above', 'row_below', 'remove_row', 'undo', 'redo' ]
    height: 360
    stretchH: 'all'
    columnSorting: true
    colHeaders: ['', 'Name', 'Description', 'Type', 'Visible']
    columns: [
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

  initialize: ->
    console.log 'initialize view'
    #@collection.bind('reset', @addAll)
    @collection.once('sync', @onCollectionSync , @)

  onCollectionSync: =>
    table_options.data = @collection.toJSON()
    @getNodeTypes()

  getNodeTypes: ->
    console.log 'getNodeTypes'
    $.ajax({
      url: '/api/nodes-types.json'
      dataType: 'json'
      success: @onNodesTypesSucess
    })

  onNodesTypesSucess: (response) =>
    nodes_type = response
    table_options.columns[3].source = nodes_type
    table_options.afterChange       = @onTableChange
    table_options.afterRemoveRow    = @onTableRemoveRow
    table_options.afterCreateRow    = @onTableCreateRow
    # Setup HandsOnTable
    table = new Handsontable( document.getElementById('visualization-table-nodes') , table_options )

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

  addNodeType: (type) ->
    nodes_type.push type
    table_options.columns[3].source = nodes_type
  
  render: =>
    return this
