class VisualizationGraphConfiguration extends Backbone.View

  onChangeValue: (e) =>
    Backbone.trigger 'visualization.config.updateParam', {name: $(e.target).attr('name'), value: $(e.target).val()}

  onToogleLabels: (e) =>
    Backbone.trigger 'visualization.config.toogleLabels', {value: $(e.target).prop('checked')}
  
  onToogleNoRelations: (e) =>
    Backbone.trigger 'visualization.config.toogleNodesWithoutRelation', {value: $(e.target).prop('checked')}

  render: -> 
    # Visualization Styles
    @$el.find('#hideLabels').change @onToogleLabels
    @$el.find('#hideNoRelations').change @onToogleNoRelations
    # Force Layout Parameters
    @$el.find('#linkdistante').change @onChangeValue
    @$el.find('#linkstrengh').change @onChangeValue
    @$el.find('#friction').change @onChangeValue
    @$el.find('#charge').change @onChangeValue
    @$el.find('#theta').change @onChangeValue
    @$el.find('#gravity').change @onChangeValue 
    return this

module.exports = VisualizationGraphConfiguration