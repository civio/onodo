Visualization = require './../models/visualization.js'

class VisualizationNetworkAnalysis extends Backbone.View

  el: '#network-analysis-modal'
  id: null

  initialize: ->
    @model = new Visualization()
  
  render: ->
    @$el.find('#network-analysis-modal-submit').click @getNetworkAnalysis

  getNetworkAnalysis: (e) =>
    e.preventDefault()
    console.log 'getNetworkAnalysis'
    @model.fetch {url: '/api/visualizations/'+@id+'/network-analysis/', success: @onNetworkAnalysisSuccess}

  onNetworkAnalysisSuccess: =>
    console.log 'network analysis success', @model.get('node_custom_fields')
    Backbone.trigger 'visualization.networkanalysis.success', {node_custom_fields: @model.get('node_custom_fields')}


module.exports = VisualizationNetworkAnalysis