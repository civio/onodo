VisualizationBase            = require './visualization-base.js'
VisualizationCanvasEdit      = require './views/visualization-canvas-edit.js'
VisualizationLegend          = require './views/visualization-legend.js'
VisualizationNavigation      = require './views/visualization-navigation.js'
VisualizationActions         = require './views/visualization-actions.js'
VisualizationShare           = require './views/visualization-share.js'
VisualizationInfo            = require './views/visualization-info.js'
VisualizationConfiguration   = require './views/visualization-configuration.js'
VisualizationTableNodes      = require './views/visualization-table-nodes.js'
VisualizationTableRelations  = require './views/visualization-table-relations.js'
VisualizationNetworkAnalysis = require './views/visualization-network-analysis.js'
BootstrapSwitch              = require 'bootstrap-switch'

class VisualizationEdit extends VisualizationBase

  mainHeaderHeight:             82
  visualizationHeaderHeight:    null
  tableHeaderHeight:            40

  visualizationConfiguration:   null
  visualizationNetworkAnalysis: null

  tableNodes:      null
  tableRelations:  null
  $table:          null
  $tableSelector:  null
  $window:         $(window)


  # Override Super Methods
  # ----------------------

  constructor: (_id) ->
    @id = _id
    @setupData()
    # Setup Views
    @visualizationCanvas         = new VisualizationCanvasEdit()
    @visualizationLegend         = new VisualizationLegend()
    @visualizationNavigation     = new VisualizationNavigation()
    @visualizationActions        = new VisualizationActions {collection: @nodes}
    @visualizationShare          = new VisualizationShare()
    @visualizationInfo           = new VisualizationInfo()

    # Setup tables
    @tableNodes      = new VisualizationTableNodes     {model: @visualization, collection: @nodes}
    @tableRelations  = new VisualizationTableRelations {model: @visualization, collection: @relations}
    # Attach nodes to VisualizationTableRelations
    @tableRelations.setNodes @nodes
    # Setup visualization table
    @$table = $('.visualization-table')
    # Setup Visualization Configuration panel
    @visualizationConfiguration = new VisualizationConfiguration()
    # Setup Visualization Configuration panel Show/Hide
    $('.visualization-graph-menu-actions .btn-configure').click @onPanelConfigureShow
    $('.visualization-graph-panel-configuration .close').click  @onPanelConfigureHide
    # Setup Visualization Network Analysis
    @visualizationNetworkAnalysis = new VisualizationNetworkAnalysis()
    @visualizationNetworkAnalysis.id = @id
    @visualizationNetworkAnalysis.render()
    # Setup scrollbar link
    $('.visualization-table-scrollbar a').click @scrollToEdit 
    # Setup scroll handler
    @$window.scroll @onScroll
    # Setup Table Tab Selector
    $('#visualization-table-selector > li > a').click @updateTable
    # Network analysis handler
    $('#network-analysis-modal-submit').click @getNetworkAnalysis

  getNetworkAnalysis: (e) =>
    e.preventDefault()


  onSync: =>
    # Render Tables & Graph when all collections ready
    @tableNodes.render()
    @tableRelations.render()
    # Listen to Network Analysis modal switches events
    $('#network-analysis-modal .switch').bootstrapSwitch()
    @bindCollectionEvents()
    super()
    # Setup Visualization Configuration
    @visualizationConfiguration.model = @visualization
    @visualizationConfiguration.render @parameters, @parametersDefault
    # Show visualization empty msg if there is no nodes or relations
    if @nodes.models.length == 0 and @relations.models.length == 0
      $('.visualization-graph-component .visualization-empty-msg').fadeIn().find('a').click @scrollToEdit
      @nodes.once 'add', ->
        $('.visualization-graph-component .visualization-empty-msg').fadeOut()

  bindCollectionEvents: ->
    # Listen to Collection events (handle tables changes)
    @nodes.on 'add',                      @onNodesAdd, @
    @nodes.on 'change:name',              @onNodeChangeName, @
    @nodes.on 'change:node_type',         @onNodeChangeType, @
    @nodes.on 'change:description',       @onNodeChangeDescription, @
    @nodes.on 'change:visible',           @onNodeChangeVisible, @
    @nodes.on 'change:image',             @onNodeChangeImage, @
    @nodes.on 'remove',                   @onNodesRemove, @
    @relations.on 'change:source_id',     @onRelationsChangeNode, @
    @relations.on 'change:target_id',     @onRelationsChangeNode, @
    @relations.on 'change:relation_type', @onRelationsChangeType, @
    @relations.on 'change:direction',     @onRelationsChangeDirection, @
    @relations.on 'remove',               @onRelationsRemove, @
    @visualization.on 'change:node_custom_fields', @onVisualizationChangeNodeCustomField, @
    # Add event handler for each custom_field
    if @visualization.get('node_custom_fields')
      @visualization.get('node_custom_fields').forEach (custom_field) =>
        @nodes.on 'change:'+custom_field.name, @onNodeChangeCustomField, @

  unbindCollectionEvents: ->
    # Listen to Collection events (handle tables changes)
    @nodes.off 'add'
    @nodes.off 'change:name'
    @nodes.off 'change:node_type'
    @nodes.off 'change:description'
    @nodes.off 'change:visible'
    @nodes.off 'change:image'
    @nodes.off 'remove'
    @relations.off 'change:source_id'
    @relations.off 'change:target_id'
    @relations.off 'change:relation_type'
    @relations.off 'change:direction'
    @relations.off 'remove'
    @visualization.off 'change:node_custom_fields'
    # Add event handler for each custom_field
    if @visualization.get('node_custom_fields')
      @visualization.get('node_custom_fields').forEach (custom_field) =>
        @nodes.off 'change:'+custom_field.name

  # Override bindVisualizationEvents to add config events
  bindVisualizationEvents: ->
    super()
    # Listen to Config Panel events
    Backbone.on 'visualization.config.updateNodesColor',            @onUpdateNodesColor, @
    Backbone.on 'visualization.config.updateNodesColorColumn',      @onUpdateNodesColorColumn, @
    Backbone.on 'visualization.config.updateNodesSize',             @onUpdateNodesSize, @
    Backbone.on 'visualization.config.updateNodesSizeColumn',       @onUpdateNodesSizeColumn, @
    Backbone.on 'visualization.config.toogleNodesLabel',            @onToogleNodesLabel, @
    Backbone.on 'visualization.config.toogleNodesLabelComplete',    @onToogleNodesLabelComplete, @
    Backbone.on 'visualization.config.toogleNodesImage',            @onToogleNodesImage, @
    Backbone.on 'visualization.config.toogleShowLegend',            @onToogleShowLegend, @
    ###
    Backbone.on 'visualization.config.toogleNodesWithoutRelation',  @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateRelationsCurvature',    @onUpdateRelationsCurvature, @
    ###
    Backbone.on 'visualization.config.updateRelationsLineStyle',    @onUpdateRelationsLineStyle, @
    Backbone.on 'visualization.config.updateForceLayoutParam',      @onUpdateForceLayoutParam, @
    Backbone.on 'visualization.networkanalysis.success',            @onNetworkAnalysisSuccess, @

  unbindVisualizationEvents: ->
    super()
    # Listen to Config Panel events
    Backbone.off 'visualization.config.updateNodesColor'
    Backbone.off 'visualization.config.updateNodesColorColumn'
    Backbone.off 'visualization.config.updateNodesSize'
    Backbone.off 'visualization.config.updateNodesSizeColumn'
    Backbone.off 'visualization.config.toogleNodesLabel'
    Backbone.off 'visualization.config.toogleNodesImage'
    Backbone.off 'visualization.config.toogleShowLegend'
    ###
    Backbone.off 'visualization.config.toogleNodesWithoutRelation'
    Backbone.off 'visualization.config.updateRelationsCurvature'
    ###
    Backbone.off 'visualization.config.updateRelationsLineStyle'
    Backbone.off 'visualization.config.updateForceLayoutParam'
    Backbone.off 'visualization.networkanalysis.success'

  resize: =>
    windowHeight = $(window).height()
    if !$('body').hasClass('fullscreen')
      @visualizationHeaderHeight = $('.visualization-graph .visualization-header').outerHeight()
      graphHeight = windowHeight - @mainHeaderHeight - @visualizationHeaderHeight - @tableHeaderHeight
      tableHeight = (windowHeight*0.5) + @tableHeaderHeight
      @$table.css 'top', graphHeight + @visualizationHeaderHeight
      @$table.height tableHeight
      @tableNodes.setSize tableHeight, @$table.offset().top
      @tableRelations.setSize tableHeight, @$table.offset().top
      @visualizationCanvas.$el.height graphHeight
    else 
      graphHeight = windowHeight
      @visualizationCanvas.$el.height graphHeight
    super()

  render: ->
    super()
    @setupAffix()

  
  # Edit Auxiliar Methods
  # ---------------------

  setupAffix: ->
    $('.visualization-graph').affix
      offset:
        top: @mainHeaderHeight + @visualizationHeaderHeight

  # On Scroll to edit click Event Handler
  scrollToEdit: (e) ->
    e.preventDefault()
    $(e.target).trigger 'blur'
    $('html, body').animate { scrollTop: $(document).height() }, 1000

  # Scroll Event Handler
  onScroll: =>
    if @visualizationCanvas
      offset = @$window.scrollTop() - @mainHeaderHeight - @visualizationHeaderHeight
      $('.visualization-graph-component').css 'margin-top', if offset > 0 then -(offset*0.5)|0 else ''

  # Update table on table selector change
  updateTable: (e) =>
    e.preventDefault()
    $target = $(e.target)
    if $target.parent().hasClass('active')
      return
    # Show tab
    $target.tab('show')
    # Update table panel
    @$table.find('.tab-pane.active').removeClass('active')
    @$table.find($target.attr('href')).addClass('active')
    # Update handsontable tables
    if $target.attr('href') == '#nodes'
      @tableRelations.hide()
      @tableNodes.show()
    else
      @tableNodes.hide()
      @tableRelations.show()

  clearData: ->
    # unbind events
    @unbindCollectionEvents()
    @unbindVisualizationEvents()
    # clear current nodes & relations
    @nodes.reset()
    @relations.reset()
    @onNodeHideInfo()
    @visualizationCanvas.clear()

  updateData: ->
    # update collections data
    syncCounter = _.after 2, @onUpdatedData
    @nodes.fetch          {url: '/api/visualizations/'+@id+'/nodes/',     success: syncCounter}
    @relations.fetch      {url: '/api/visualizations/'+@id+'/relations/', success: syncCounter}
      
  onUpdatedData: =>
    # update tables collections
    @tableNodes.render()
    @tableRelations.render()
    @visualizationCanvas.setup @getVisualizationCanvasData(@nodes.models, @relations.models), @parameters
    @visualizationCanvas.render()
    @visualizationActions.updateSearchData()
    # bind events again
    @bindCollectionEvents()
    @bindVisualizationEvents()
    Backbone.trigger 'visualization.synced'


  # Events Handlers Methods
  # ---------------------

  # Nodes Collection Events
  onNodesAdd: (node) ->
    #console.log 'nodes add'
    # We need to wait until sync event to get node id
    @nodes.once 'sync', (model) =>
      #console.log 'onNodesAdd', model.id, model
      @visualizationCanvas.addNode model.attributes
      @visualizationActions.updateSearchData()
    , @

  onNodeChangeName: (node) ->
    #console.log 'onNodeChangeName', node
    # Update nodes labels
    @visualizationCanvas.updateNodeLabel node
    # Update Panel Info name
    @updateInfoNode node
    @visualizationActions.updateSearchData()

  onNodeChangeType: (node) ->
    # Update node color if nodesColor is a qualitative or quantitative scale & depends on nodes_type
    if (@parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative') and @parameters.nodesColorColumn == 'node_type' 
      @visualizationCanvas.updateNodesColorValue()
    # Update Panel Info description
    @updateInfoNode node

  onNodeChangeDescription: (node) ->
    #console.log 'onNodeChangeDescription', node.attributes.description
    # Update Panel Info description
    @updateInfoNode node

  onNodeChangeVisible: (node) ->
    #console.log 'onNodeChangeVisibe', node
    if node.attributes.visible
      @visualizationCanvas.showNode node.attributes
    else
      @visualizationCanvas.hideNode node.attributes
      # Hide Panel Info if visible for current node
      if @visualizationInfo.isVisible() and @visualizationInfo.node.id == node.id
        @visualizationInfo.hide()
    @visualizationActions.updateSearchData()

  onNodeChangeImage: (node) ->
    #console.log 'onNodeChangeImage', node
    @visualizationCanvas.updateNodeImage node

  onNodeChangeCustomField: (node, value, options) ->
    changed_custom_field =  Object.keys(node.changedAttributes())[0]
    # Update node color if nodesColor is a qualitative or quantitative scale & depends on changed custom_field
    if (@parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative') and @parameters.nodesColorColumn == changed_custom_field 
      @visualizationCanvas.updateNodesColorValue()
    # Update Panel Info description
    @updateInfoNode node

  # When a node_custom_field is added, we add a listener to new custom_field
  onVisualizationChangeNodeCustomField: =>
    # update custom_fields listeners
    if @visualization.get('node_custom_fields')
      @visualization.get('node_custom_fields').forEach (custom_field) =>
        @nodes.off 'change:'+custom_field.name
        @nodes.on 'change:'+custom_field.name, @onNodeChangeCustomField, @

  onNodesRemove: (node) ->
    #console.log 'onNodesRemove', node.attributes.name
    @visualizationCanvas.removeNode node.attributes
    @visualizationActions.updateSearchData()
    # Hide Panel Info if visible for current node
    if @visualizationInfo.isVisible() and @visualizationInfo.node.id == node.id
      @visualizationInfo.hide()

  # Relations Collection Events
  onRelationsChangeNode: (relation) ->
    #console.log 'onRelationsChange', relation
    # check if we have both source_id and target_id
    if relation.attributes.source_id and relation.attributes.target_id
      # Update relation node
      @visualizationCanvas.updateRelationNode relation.attributes

  onRelationsChangeType: (relation) ->
    #console.log 'onRelationsChangeType', relation
    @visualizationCanvas.updateRelationsLabelsData relation.attributes

  onRelationsChangeDirection: (relation) ->
    @visualizationCanvas.redraw()

  onRelationsRemove: (relation) ->
    @visualizationCanvas.removeRelation relation.attributes


  # Panel Events
  onPanelConfigureShow: =>
    $('html, body').animate { scrollTop: 0 }, 400
    @visualizationConfiguration.$el.addClass 'active'
    $('.visualization-graph-component').css 'margin-left', -200

  onPanelConfigureHide: =>
    @visualizationConfiguration.$el.removeClass 'active'
    $('.visualization-graph-component').css 'margin-left', 0

  onUpdateNodesColor: (e) ->
    @visualizationCanvas.updateNodesColor e.value

  onUpdateNodesColorColumn: (e) ->
    @visualizationCanvas.updateNodesColorColumn e.value

  onUpdateNodesSize: (e) ->
    @visualizationCanvas.updateNodesSize e.value

  onUpdateNodesSizeColumn: (e) ->
    @visualizationCanvas.updateNodesSizeColumn e.value

  onToogleNodesLabel: (e) ->
    @visualizationCanvas.redraw()

  onToogleNodesLabelComplete: (e) ->
    @visualizationCanvas.redraw()

  onToogleNodesImage: (e) ->
    @visualizationCanvas.toogleNodesImage e.value

  onToogleShowLegend: (e) ->
    @visualizationLegend.toggle()
  
  ###
  onToogleNodesWithoutRelation: (e) ->
    @visualizationCanvas.toogleNodesWithoutRelation e.value

  onUpdateRelationsCurvature: (e) ->
    @visualizationCanvas.updateRelationsCurvature e.value
  ###

  onUpdateRelationsLineStyle: (e) ->
    @visualizationCanvas.redraw()

  onUpdateForceLayoutParam: (e) ->
    @visualizationCanvas.updateForceLayoutParameter e.name, e.value

  onNetworkAnalysisSuccess: (e) ->
    # Activate nodes tab
    $('#visualization-table-selector > li > a[href=#nodes]').trigger 'click'
    # Update vusalization model & nodes collection in Nodes Table
    @tableNodes.addNetworkAnalysisColumns e.visualization, e.nodes

  # Auxiliar Info Node method
  updateInfoNode: (node) ->
    if @visualizationInfo.isVisible() and @visualizationInfo.model.id == node.id
      #@visualizationInfo.model = node
      #@visualizationInfo.render()
      @visualizationInfo.show node, @visualization.get('node_custom_fields')
  
module.exports = VisualizationEdit