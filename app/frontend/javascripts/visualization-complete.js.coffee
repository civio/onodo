# Imports
VisualizationModel           = require './models/visualization.js'
NodesCollection              = require './collections/nodes-collection.js'
RelationsCollection          = require './collections/relations-collection.js'
VisualizationGraph           = require './views/visualization-graph.js'
VisualizationTableNodes      = require './views/visualization-table-nodes.js'
VisualizationTableRelations  = require './views/visualization-table-relations.js'

class Visualization extends VisualizationBase

  mainHeaderHeight:             84
  visualizationHeaderHeight:    null
  tableHeaderHeight:            42

  id:                           null
  edit:                         false
  story:                        false
  nodes:                        null
  visualizationGraph:           null
  visualizationTable:           null
  visualizationTableNodes:      null
  visualizationTableRelations:  null
  $tableSelector:               null

  constructor: (_id, _edit, _story) ->
    @id    = _id
    @edit  = _edit
    @story = _story || false
    console.log 'setup visualization', @story, @edit
    # Setup Visualization Model
    @visualization  = new VisualizationModel()
    # Setup Collections
    @nodes          = new NodesCollection()
    @relations      = new RelationsCollection()
    # Setup Tables for Edit Mode
    if !@story and @edit 
      @visualizationTableNodes      = new VisualizationTableNodes {model: @visualization, collection: @nodes}
      @visualizationTableRelations  = new VisualizationTableRelations {model: @visualization, collection: @relations}
      # Attach nodes to VisualizationTableRelations
      @visualizationTableRelations.setNodes @nodes
      # Setup visualization table
      @visualizationTable = $('.visualization-table')
      # Setup scrollbar link
      $('.visualization-table-scrollbar a').click (e) ->
        e.preventDefault()
        $('html, body').animate { scrollTop: $(document).height() }, 1000
      # Setup scroll handler
      $(window).scroll @onScroll
    # Setup Visualization Graph View
    @visualizationGraph           = new VisualizationGraph {model: @visualization, collection: {nodes: @nodes, relations: @relations}, edit: @edit}
    # Setup Table Tab Selector
    $('#visualization-table-selector > li > a').click @updateTable

  render: ->
    # force resize
    @resize()
    # Setup affix bootstrap
    if !@story and @edit
      @setupAffix()
    # fetch model & collections
    syncCounter = _.after 3, @onSync
    @visualization.fetch  {url: '/api/visualizations/'+@id,               success: syncCounter}
    @nodes.fetch          {url: '/api/visualizations/'+@id+'/nodes/',     success: syncCounter}
    @relations.fetch      {url: '/api/visualizations/'+@id+'/relations/', success: syncCounter}

  resize: =>
    console.log 'resize!'
    if !@story and @edit
      windowHeight = $(window).height()
      @visualizationHeaderHeight = $('.visualization-graph .visualization-header').outerHeight()
      graphHeight = windowHeight - @mainHeaderHeight - @visualizationHeaderHeight - @tableHeaderHeight
      tableHeight = (windowHeight*0.5) + @tableHeaderHeight
      @visualizationTable.css 'top', graphHeight + @visualizationHeaderHeight
      @visualizationTable.height tableHeight
      @visualizationTableNodes.setSize tableHeight, @visualizationTable.offset().top
      @visualizationTableRelations.setSize tableHeight, @visualizationTable.offset().top
      @visualizationGraph.$el.height graphHeight
      #$('.footer').css 'top', graphHeight + @visualizationHeaderHeight
    @visualizationGraph.resize()

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: @mainHeaderHeight + @visualizationHeaderHeight

  updateTable: (e) =>
    e.preventDefault()
    if $(e.target).parent().hasClass('active')
      return
    # Show tab
    $(e.target).tab('show')
    # Update table
    $('.visualization-table .tab-pane.active').removeClass('active');
    $('.visualization-table '+$(e.target).attr('href')).addClass('active')
    if @edit
      if $(e.target).attr('href') == '#nodes'
        @visualizationTableRelations.hide()
        @visualizationTableNodes.show()
      else
        @visualizationTableNodes.hide()
        @visualizationTableRelations.show()

  showChapter: (nodes, relations) ->
    @visualizationGraph.showChapter nodes, relations

  onScroll: =>
    @visualizationGraph.setOffsetY $(window).scrollTop() - @mainHeaderHeight - @visualizationHeaderHeight

  onSync: =>
    # Render Tables & Graph when all collections ready
    if !@story and @edit
      @visualizationTableNodes.render()
      @visualizationTableRelations.render()
    @visualizationGraph.render @edit, @story
    Backbone.trigger 'visualization.synced'

module.exports = Visualization