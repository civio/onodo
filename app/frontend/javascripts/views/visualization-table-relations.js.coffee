Handsontable             = require './../dist/handsontable.full.js'
VisualizationTableBase   = require './visualization-table-base.js'

class VisualizationTableRelations extends VisualizationTableBase

  el:               '.visualization-table-relations'
  relations_types:  null
  nodes:            null
  tableColHeaders:  ['', 'Source', 'Relationship', 'Target', 'Date', '<a class="add-custom-column" title="Create Custom Column" href="#"></a>']

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
    console.log 'table relations nodes sync', @table_options.columns[1].source
    @table_options.columns[1].source = @table_options.columns[3].source = @nodes.toJSON().map((d) -> return d.name).sort()
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
  addModel: (index) ->
    # We need to set `wait = true` to wait for the server before adding the new model to the collection
    # http://backbonejs.org/#Collection-create
    model = @collection.create {dataset_id: $('body').data('id'), wait: true}
    # We wait until model is synced in server to get its id
    @collection.once 'sync', () ->
      @table.setDataAtRowProp index, 'id', model.id
    , @

  # Method called from parent class `VisualizationTableBase`  
  updateModel: (change) =>
    index = change[0]
    key   = change[1]
    value = change[3]
    # Get model id in order to acced to model in Collection
    model_id = @table.getDataAtRowProp(index, 'id')
    if model_id
      model = @collection.get model_id
      # Add new node_type to nodes_types array
      if key == 'relation_type' && !_.contains(@relations_types, value)
        @addRelationsType value
      # Setup parameters to store in model
      obj = {}
      if key == 'source_name' or key == 'target_name'
        node = @nodes.filter((d) -> return d.attributes.name == value)  # get node by node name
        if node
          if key == 'source_name'
            obj.source_id = node[0].id
          else
            obj.target_id = node[0].id
      else
        obj[ key ] = value
      # Save model with updated attributes in order to delegate in Collection trigger 'change' events
      model.save obj

  addRelationsType: (type) ->
    @relations_types.push type
    @setRelationsTypesSource()

  # Set 'Node Type' column source in table_options
  setRelationsTypesSource: ->
    @table_options.columns[2].source = @relations_types

  removeRelationsWithNode: (node) ->
    # descending loop though all relations
    for relation, i in @table_options.data by -1
      # if relation contains removed node in source or target we remove that relation
      if relation.source_id == node.id or relation.target_id == node.id
        @table.alter('remove_row', i, 1 )  

module.exports = VisualizationTableRelations
