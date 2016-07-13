Visualization = require './../models/visualization.js'

class VisualizationNetworkAnalysis extends Backbone.View

  el: '#network-analysis-modal'
  id: null

  render: ->
    @$el.find('#network-analysis-modal-submit').click @getNetworkAnalysis

  getNetworkAnalysis: (e) =>
    e.preventDefault()
    # add loader!
    console.log 'getNetworkAnalysis'
    $.ajax {
      url:     '/api/visualizations/'+@id+'/network-analysis/'
      success: @onNetworkAnalysisSuccess
    }
    
  onNetworkAnalysisSuccess: (data) =>
    @$el.modal('hide')
    # remove loader!
    Backbone.trigger 'visualization.networkanalysis.success', {node_custom_fields: data.node_custom_fields}


module.exports = VisualizationNetworkAnalysis