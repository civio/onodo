class VisualizationGraphConfigurationView extends Backbone.View

  onChangeValue: (e) =>
    Backbone.trigger 'config.param.change', {name: $(e.target).attr('name'), value: $(e.target).val()}

  render: -> 
    @$el.find('#linkdistante').change @onChangeValue
    @$el.find('#linkstrengh').change @onChangeValue
    @$el.find('#friction').change @onChangeValue
    @$el.find('#charge').change @onChangeValue
    @$el.find('#theta').change @onChangeValue
    @$el.find('#gravity').change @onChangeValue
    return this

module.exports = VisualizationGraphConfigurationView