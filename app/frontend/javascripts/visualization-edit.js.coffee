VisualizationBase            = require './visualization-base.js'
VisualizationConfiguration   = require './views/visualization-configuration.js'
VisualizationTableNodes      = require './views/visualization-table-nodes.js'
VisualizationTableRelations  = require './views/visualization-table-relations.js'
BootstrapSwitch              = require 'bootstrap-switch'

class VisualizationEdit extends VisualizationBase

  mainHeaderHeight:             84
  visualizationHeaderHeight:    null
  tableHeaderHeight:            42

  visualizationConfiguration:   null

  tableNodes:      null
  tableRelations:  null
  $table:          null
  $tableSelector:  null
  $window:         $(window)


  # Override Super Methods
  # ----------------------

  constructor: (_id) ->
    console.log 'Visualization Edit'
    super _id
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
    # Setup scrollbar link
    $('.visualization-table-scrollbar a').click (e) ->
      e.preventDefault()
      $('html, body').animate { scrollTop: $(document).height() }, 1000
    # Setup scroll handler
    @$window.scroll @onScroll
    # Setup Table Tab Selector
    $('#visualization-table-selector > li > a').click @updateTable

  onSync: =>
    # Render Tables & Graph when all collections ready
    @tableNodes.render()
    @tableRelations.render()
    # Listen to Network Analysis modal switches events
    $('#network-analysis-modal .switch').bootstrapSwitch()
    # Listen to Collection events (handle tables changes)
    @nodes.bind 'add',                      @onNodesAdd, @
    @nodes.bind 'change:name',              @onNodeChangeName, @
    @nodes.bind 'change:node_type',         @onNodeChangeType, @
    @nodes.bind 'change:description',       @onNodeChangeDescription, @
    @nodes.bind 'change:visible',           @onNodeChangeVisible, @
    @nodes.bind 'change:image',             @onNodeChangeImage, @
    @nodes.bind 'remove',                   @onNodesRemove, @
    @relations.bind 'change:source_id',     @onRelationsChangeNode, @
    @relations.bind 'change:target_id',     @onRelationsChangeNode, @
    @relations.bind 'change:relation_type', @onRelationsChangeType, @
    @relations.bind 'change:direction',     @onRelationsChangeDirection, @
    @relations.bind 'remove',               @onRelationsRemove, @
    # Listen to Config Panel events
    Backbone.on 'visualization.config.updateNodesColor',            @onUpdateNodesColor, @
    Backbone.on 'visualization.config.updateNodesColorColumn',      @onUpdateNodesColorColumn, @
    Backbone.on 'visualization.config.updateNodesSize',             @onUpdateNodesSize, @
    Backbone.on 'visualization.config.toogleNodesLabel',            @onToogleNodesLabel, @
    Backbone.on 'visualization.config.toogleNodesImage',            @onToogleNodesImage, @
    Backbone.on 'visualization.config.toogleNodesWithoutRelation',  @onToogleNodesWithoutRelation, @
    Backbone.on 'visualization.config.updateRelationsCurvature',    @onUpdateRelationsCurvature, @
    Backbone.on 'visualization.config.updateRelationsLineStyle',    @onUpdateRelationsLineStyle, @
    Backbone.on 'visualization.config.updateForceLayoutParam',      @onUpdateForceLayoutParam, @
    super()
    # Setup Visualization Configuration
    @visualizationConfiguration.model = @visualization
    @visualizationConfiguration.render @parameters

  resize: =>
    # setup container height
    #h = if $('body').hasClass('fullscreen') then @$window.height() else @$window.height() - 178 # -50-64-64
    #console.log 'resize'
    windowHeight = $(window).height()
    @visualizationHeaderHeight = $('.visualization-graph .visualization-header').outerHeight()
    graphHeight = windowHeight - @mainHeaderHeight - @visualizationHeaderHeight - @tableHeaderHeight
    tableHeight = (windowHeight*0.5) + @tableHeaderHeight
    @$table.css 'top', graphHeight + @visualizationHeaderHeight
    @$table.height tableHeight
    @tableNodes.setSize tableHeight, @$table.offset().top
    @tableRelations.setSize tableHeight, @$table.offset().top
    @visualizationCanvas.$el.height graphHeight
    #$('.footer').css 'top', graphHeight + @visualizationHeaderHeight
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

  # Scroll Event Handler
  onScroll: =>
    if @visualizationCanvas
      @visualizationCanvas.setOffsetY @$window.scrollTop() - @mainHeaderHeight - @visualizationHeaderHeight

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


  # Events Handlers Methods
  # ---------------------

  # Nodes Collection Events
  onNodesAdd: (node) ->
    # We need to wait until sync event to get node id
    @nodes.once 'sync', (model) =>
      console.log 'onNodesAdd', model.id, model
      @visualizationCanvas.addNode model.attributes
    , @

  onNodeChangeName: (node) ->
    console.log 'onNodeChangeName', node.attributes.name
    # Update nodes labels
    @visualizationCanvas.updateNodesLabels()
    # Update Panel Info name
    @updateInfoNode node

  onNodeChangeType: (node) ->
    console.log 'onNodeChangeType', node.attributes.name
    @visualizationCanvas.updateNodesType()
    @updateInfoNode node

  onNodeChangeDescription: (node) ->
    console.log 'onNodeChangeDescription', node.attributes.description
    # Update Panel Info description
    @updateInfoNode node

  onNodeChangeVisible: (node) ->
    console.log 'onNodeChangeVisibe', node
    if node.attributes.visible
      @visualizationCanvas.showNode node.attributes
    else
      @visualizationCanvas.hideNode node.attributes
      # Hide Panel Info if visible for current node
      if @visualizationInfo.isVisible() and @visualizationInfo.node.id == node.id
        @visualizationInfo.hide()

  onNodeChangeImage: (node) ->
    console.log 'onNodeChangeImage', node
    @visualizationCanvas.updateImages()
    @visualizationCanvas.updateNodes()
    @visualizationCanvas.updateForce true

  onNodeChangeCustomField: (node) ->
    # Update Panel Info description
    @updateInfoNode node

  onNodesRemove: (node) ->
    console.log 'onNodesRemove', node.attributes.name
    @visualizationCanvas.removeNode node.attributes
    # Hide Panel Info if visible for current node
    if @visualizationInfo.isVisible() and @visualizationInfo.node.id == node.id
      @visualizationInfo.hide()

  # Relations Collection Events
  onRelationsChangeNode: (relation) ->
    console.log 'onRelationsChange', relation
    # check if we have both source_id and target_id
    if relation.attributes.source_id and relation.attributes.target_id
      # Remove relation if exist in graph
      @visualizationCanvas.removeVisibleRelationData relation.attributes
      # Add relation
      @visualizationCanvas.addRelation relation.attributes

  onRelationsChangeType: (relation) ->
    console.log 'onRelationsChangeType', relation
    @visualizationCanvas.updateRelationsLabelsData()

  onRelationsChangeDirection: (relation) ->
    @visualizationCanvas.updateRelations()
    @visualizationCanvas.updateForce true

  onRelationsRemove: (relation) ->
    @visualizationCanvas.removeRelation relation.attributes


  # Panel Events
  onPanelConfigureShow: =>
    $('html, body').animate { scrollTop: 0 }, 600
    @visualizationConfiguration.$el.addClass 'active'
    @visualizationCanvas.setOffsetX 200 # half the width of Panel Configuration

  onPanelConfigureHide: =>
    @visualizationConfiguration.$el.removeClass 'active'
    @visualizationCanvas.setOffsetX 0

  onUpdateNodesColor: (e) ->
    @visualizationCanvas.updateNodesColor e.value

  onUpdateNodesColorColumn: (e) ->
    # TODO!!! Add updateNodesColorColumn method in VisualizationCanvas
    @visualizationCanvas.updateNodesColorColumn e.value

  onUpdateNodesSize: (e) ->
    @visualizationCanvas.updateNodesSize e.value

  onToogleNodesLabel: (e) ->
    @visualizationCanvas.toogleNodesLabel e.value

  onToogleNodesImage: (e) ->
    @visualizationCanvas.toogleNodesImage e.value
  
  onToogleNodesWithoutRelation: (e) ->
    @visualizationCanvas.toogleNodesWithoutRelation e.value

  onUpdateRelationsCurvature: (e) ->
    @visualizationCanvas.updateRelationsCurvature e.value

  onUpdateRelationsLineStyle: (e) ->
    @visualizationCanvas.updateRelationsLineStyle e.value

  onUpdateForceLayoutParam: (e) ->
    @visualizationCanvas.updateForceLayoutParameter e.name, e.value


  # Auxiliar Info Node method
  updateInfoNode: (node) ->
    if @visualizationInfo.isVisible() and @visualizationInfo.model.id == node.id
      #@visualizationInfo.model = node
      #@visualizationInfo.render()
      @visualizationInfo.show node, @visualization.get('node_custom_fields')
  
module.exports = VisualizationEdit