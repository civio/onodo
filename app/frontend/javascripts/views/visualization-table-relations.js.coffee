Handsontable             = require './../dist/handsontable.full.js'
VisualizationTableBase   = require './visualization-table-base.js'

class VisualizationTableRelations extends VisualizationTableBase

  el:               '.visualization-table-relations'
  nodes_type:       null
  tableColHeaders:  ['', 'Source', 'Target', 'Type']
  tableColumns:     [
    { 
      data: 'id'
      type: 'numeric' 
    },
    { 
      data: 'source_id' 
    },
    { 
      data: 'target_id' 
    },
    { 
      data: 'relation_type'
      #type: 'autocomplete'
      #strict: false
    }
  ]

  constructor: (@collection) ->
    super(@collection)
    console.log 'relations', @collection

    # Override Table Options
    @table_options.colHeaders  = tableColHeaders
    @table_options.columns     = tableColumns

  onCollectionSync: =>
    super()
    @setupTable()


module.exports = VisualizationTableRelations
