class VisualizationGraphConfiguration extends Backbone.View

  el: '.visualization-graph-panel-configuration'
  parameters: null

  onChangeValue: (e) =>
    key = $(e.target).attr('name')
    value = $(e.target).val()
    @parameters[ key ] = value
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: key, value: value}

  onToogleLabels: (e) =>
    @parameters.hideLabels = $(e.target).prop('checked')
    Backbone.trigger 'visualization.config.toogleLabels', {value: @parameters.hideLabels}
    @updateParameters()
  
  onToogleNoRelations: (e) =>
    @parameters.hideNoRelations = $(e.target).prop('checked')
    Backbone.trigger 'visualization.config.toogleNodesWithoutRelation', {value: @parameters.hideNoRelations}
    @updateParameters()

  onChangeRelationsCurvature: (e) =>
    @parameters.relationsCurvature = $(e.target).val()
    Backbone.trigger 'visualization.config.updateRelationsCurvature', {value: @parameters.relationsCurvature}

  onUpdateVisualizationParemeters: (e) =>
      console.log 'onUpdateVisualizationParemeters'
      # we update parameters from bootstrap-slider only when slideStop event is triggeres
      # in order to avoid redundancy
      @updateParameters()

  setupParameters: ->
    if @parameters == null
      @parameters = {}

    if @parameters.relationsCurvature
      @$el.find('#curvature').slider('setValue', parseFloat @parameters.relationsCurvature)
    if @parameters.linkDistance
      @$el.find('#linkdistance').slider('setValue', parseFloat @parameters.linkDistance)
    if @parameters.linkStrength
      @$el.find('#linkstrength').slider('setValue', parseFloat @parameters.linkStrength)
    if @parameters.friction
      @$el.find('#friction').slider('setValue', parseFloat @parameters.friction)
    if @parameters.charge
      @$el.find('#charge').slider('setValue', parseFloat @parameters.charge)
    if @parameters.theta
      @$el.find('#theta').slider('setValue', parseFloat @parameters.theta)
    if @parameters.gravity
      @$el.find('#gravity').slider('setValue', parseFloat @parameters.gravity)

  updateParameters: ->
    console.log 'updateParameters', JSON.stringify @parameters
    @model.save { parameters: JSON.stringify @parameters }

  initialize: ->
    @render()

  render: ->
    # Get parameters from model as JSON
    @parameters = JSON.parse @model.attributes.parameters
    console.log 'configuration model', @parameters
    # Setup sliders
    $sliders = @$el.find('.slider')
    $sliders.slider()
    $sliders.on 'slideStop', @onUpdateVisualizationParemeters
    # Setup parameters
    @setupParameters()
    # Visualization Styles
    @$el.find('#hideLabels').change @onToogleLabels
    @$el.find('#hideNoRelations').change @onToogleNoRelations
    @$el.find('#curvature').change @onChangeRelationsCurvature
    # Force Layout Parameters
    @$el.find('#linkdistance').change @onChangeValue
    @$el.find('#linkstrength').change @onChangeValue
    @$el.find('#friction').change @onChangeValue
    @$el.find('#charge').change @onChangeValue
    @$el.find('#theta').change @onChangeValue
    @$el.find('#gravity').change @onChangeValue
    return this

module.exports = VisualizationGraphConfiguration