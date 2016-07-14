Visualization = require './../models/visualization.js'

class VisualizationNetworkAnalysis extends Backbone.View

  el: '#network-analysis-modal'
  id: null

  render: ->
    @$el.find('#network-analysis-modal-submit').click @getNetworkAnalysis

  getNetworkAnalysis: (e) =>
    e.preventDefault()
    @$el.find('#network-analysis-modal-submit').off 'click'
    # get checkbox data
    @$el.find('.modal-body').fadeTo(250, 0)
    @$el.find('.modal-content').addClass 'loading'
    console.log 'getNetworkAnalysis'
    $.ajax {
      url:     '/api/visualizations/'+@id+'/network-analysis/'
      success: @onNetworkAnalysisSuccess
    }
    
  onNetworkAnalysisSuccess: (data) =>
    @$el.modal 'hide'
    @$el.find('.modal-content').removeClass 'loading'
    @$el.find('.modal-body').fadeTo(0, 1)
    @$el.find('#network-analysis-modal-submit').click @getNetworkAnalysis
    Backbone.trigger 'visualization.networkanalysis.success', {node_custom_fields: data.node_custom_fields}


module.exports = VisualizationNetworkAnalysis