# Imports
VisualizationModel            = require './models/visualization.js'
NodesCollection               = require './collections/nodes-collection.js'
RelationsCollection           = require './collections/relations-collection.js'
VisualizationGraph            = require './views/visualization-graph.js'
VisualizationTableNodes       = require './views/visualization-table-nodes.js'
VisualizationTableRelations   = require './views/visualization-table-relations.js'
StoryIndex                    = require './views/story-index.js'

class StoryShow

  id:                           null
  nodes:                        null
  visualizationGraph:           null
  visualizationTableNodes:      null
  visualizationTableRelations:  null
  storyIndex:                   null

  constructor: (_id) ->
    console.log('setup visualization', _id);
    @id = _id
    # Setup Visualization Model
    @visualization = new VisualizationModel()
    # Setup Collections
    @nodes      = new NodesCollection()
    @relations  = new RelationsCollection()
    # Setup Views 
    @visualizationGraph = new VisualizationGraph {model: @visualization, collection: {nodes: @nodes, relations: @relations} }
    # Setup Story Index
    @storyIndex = new StoryIndex
    # Setup 'Start reading' button interaction
    $('.story-cover .btn-start-reading').click (e) ->
      e.preventDefault()
      $('.story-cover').fadeOut()
      $('.visualization-info, .visualization-description').fadeIn()

  resize: =>
    #console.log 'resize!'
    @visualizationGraph.resize()
    # $('.visualization-table').height( windowHeight - 64 );
    #$('.footer').css 'top', graphHeight+64

  render: ->
    # force resize
    @resize()
    # fetch model & collections
    syncCounter = _.after 3, @onSync
    @visualization.fetch  {url: '/api/visualizations/'+@id,               success: syncCounter}
    @nodes.fetch          {url: '/api/visualizations/'+@id+'/nodes/',     success: syncCounter}
    @relations.fetch      {url: '/api/visualizations/'+@id+'/relations/', success: syncCounter}

  onSync: =>
    @visualizationGraph.render()

module.exports = StoryShow