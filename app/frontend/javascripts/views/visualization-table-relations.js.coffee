Handsontable             = require './../dist/handsontable.full.js'
VisualizationTableBase   = require './visualization-table-base.js'

class VisualizationTableRelations extends VisualizationTableBase

  el:               '.visualization-table-relations'
  nodes_type:       null
  tableColHeaders:  ['', 'Source', 'Relationship', 'Target', 'Date']
  
  constructor: (@collection) ->
    super @collection, 'relation'
    # Override Table Options
    @table_options.colHeaders  = @tableColHeaders
    @table_options.columns     = @getTableColumns()

  onCollectionSync: =>
    super()
    console.log 'data!', @table_options.data
    @setupTable()

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
      },
      { 
        data: 'relation_type'
        #type: 'autocomplete'
        #strict: false
      },
      { 
        data: 'target_name' 
      },
      { 
        data: '' 
      }
    ]


module.exports = VisualizationTableRelations
