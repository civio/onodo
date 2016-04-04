Handsontable             = require './../dist/handsontable.full.js'
VisualizationTableBase   = require './visualization-table-base.js'

class VisualizationTableRelations extends VisualizationTableBase

  el:               '.visualization-table-relations'
  relations_types:  null
  nodes:            null
  tableColHeaders:  ['', 'Source', 'Relationship', 'Target', 'Date']

  constructor: (@collection) ->
    super @collection, 'relation'
    # Override Table Options
    @table_options.colHeaders  = @tableColHeaders
    @table_options.columns     = @getTableColumns()

  onCollectionSync: =>
    super()
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
        data: '' 
      }
    ]

  setNodes: (_nodes) ->
    @nodes = _nodes
    #@nodes.once 'sync', @updateNodes, @
    @nodes.on 'update', @updateNodes, @
    @nodes.on 'change:name', @updateNodes, @

  updateNodes: ->
    @table_options.columns[1].source = @table_options.columns[3].source = @nodes.toJSON().map((d) -> return d.name).sort()
    console.log 'table relations nodes sync', @table_options.columns[1].source
    # update table settings when needed
    if @table
      @table.updateSettings @table_options

  getRelationsTypes: =>
    #console.log 'getRelationsTypes'
    $.ajax {
      url: '/api/visualizations/'+$('body').data('id')+'/relations/types.json'
      dataType: 'json'
      success: @onRelationsTypesSucess
    }

  onRelationsTypesSucess: (response) =>
    @relations_types = response
    @setRelationsTypesSource()
    @setupTable()

  # Method called from parent class `VisualizationTableBase`  
  updateModel: (change) =>
    index = change[0]
    key   = change[1]
    value = change[3]
    # Get model id in order to acced to model in Collection
    model_id = @table.getDataAtRowProp(index, 'id')
    model = @collection.get model_id
    console.log 'updateRelation', change, model
    # Add new node_type to nodes_types array
    if key == 'relation_type' && !_.contains(@relations_types, value)
      @addRelationsType value
    obj = {}
    obj[ key ] = value
    # Save model with updated attributes in order to delegate in Collection trigger 'change' events
    model.save obj

  addRelationsType: (type) ->
    @relations_types.push type
    @setRelationsTypesSource()

  # Set 'Node Type' column source in table_options
  setRelationsTypesSource: ->
    @table_options.columns[2].source = @relations_types

module.exports = VisualizationTableRelations
