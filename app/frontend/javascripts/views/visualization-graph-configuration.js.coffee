class VisualizationGraphConfiguration extends Backbone.View

  el: '.visualization-graph-panel-configuration'
  parameters: null
  parametersDefault: {
    relationsCurvature: 1
    linkDistance:       100
    linkStrength:       1
    friction:           0.9
    charge:             -150
    theta:              0.8
    gravity:            0.1
  }

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
    # we update parameters from bootstrap-slider only when slideStop event is triggeres
    # in order to avoid redundancy
    @updateParameters()

  onResetDefaults: (e) =>
    e.preventDefault()
    $(e.target).blur()
    # we only reset force layout params
    @parameters.linkDistance        = @parametersDefault.linkDistance
    @parameters.linkStrength        = @parametersDefault.linkStrength
    @parameters.friction            = @parametersDefault.friction
    @parameters.charge              = @parametersDefault.charge
    @parameters.theta               = @parametersDefault.theta
    @parameters.gravity             = @parametersDefault.gravity
    @setupSlidersValues()
    @updateParameters()

  setupParameters: ->
    @parameters = @parameters || {}
    @parameters.relationsCurvature  = @parameters.relationsCurvature || @parametersDefault.relationsCurvature
    @parameters.linkDistance        = @parameters.linkDistance || @parametersDefault.linkDistance
    @parameters.linkStrength        = @parameters.linkStrength || @parametersDefault.linkStrength
    @parameters.friction            = @parameters.friction || @parametersDefault.friction
    @parameters.charge              = @parameters.charge || @parametersDefault.charge
    @parameters.theta               = @parameters.theta || @parametersDefault.theta
    @parameters.gravity             = @parameters.gravity || @parametersDefault.gravity
    @setupSlidersValues()

  updateParameters: ->
    @model.save { parameters: JSON.stringify @parameters }

  setupSlidersValues: ->
    @$el.find('#curvature').slider    'setValue', parseFloat @parameters.relationsCurvature
    @$el.find('#linkdistance').slider 'setValue', parseFloat @parameters.linkDistance
    @$el.find('#linkstrength').slider 'setValue', parseFloat @parameters.linkStrength
    @$el.find('#friction').slider     'setValue', parseFloat @parameters.friction
    @$el.find('#charge').slider       'setValue', parseFloat @parameters.charge
    @$el.find('#theta').slider        'setValue', parseFloat @parameters.theta
    @$el.find('#gravity').slider      'setValue', parseFloat @parameters.gravity

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
    # Handle reset defaults
    @$el.find('#reset-defaults').click @onResetDefaults
    return this

module.exports = VisualizationGraphConfiguration