class VisualizationGraphConfiguration extends Backbone.View

  el: '.visualization-graph-panel-configuration'

  onChangeValue: (e) ->
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: $(e.target).attr('name'), value: $(e.target).val()}

  onToogleLabels: (e) ->
    Backbone.trigger 'visualization.config.toogleLabels', {value: $(e.target).prop('checked')}
  
  onToogleNoRelations: (e) ->
    Backbone.trigger 'visualization.config.toogleNodesWithoutRelation', {value: $(e.target).prop('checked')}

  onChangeRelationsCurvature: (e) ->
    Backbone.trigger 'visualization.config.updateRelationsCurvature', {value: $(e.target).val()}

  onUpdateVisualizationParemeters: (e) ->
      console.log 'onUpdateVisualizationParemeters'

  initialize: ->
    @render()

  render: -> 
    console.log 'configuration model', @model
    # Setup sliders
    $sliders = @$el.find('.slider')
    $sliders.slider()
    $sliders.on 'slideStop', @onUpdateVisualizationParemeters
    # Visualization Styles
    @$el.find('#hideLabels').change @onToogleLabels
    @$el.find('#hideNoRelations').change @onToogleNoRelations
    @$el.find('#curvature').change @onChangeRelationsCurvature
    # Force Layout Parameters
    @$el.find('#linkdistante').change @onChangeValue
    @$el.find('#linkstrengh').change @onChangeValue
    @$el.find('#friction').change @onChangeValue
    @$el.find('#charge').change @onChangeValue
    @$el.find('#theta').change @onChangeValue
    @$el.find('#gravity').change @onChangeValue
    return this

module.exports = VisualizationGraphConfiguration