Visualization = require './../models/visualization.js'

class VisualizationNetworkAnalysis extends Backbone.View

  el: '#network-analysis-modal'
  id: null

  render: ->
    @$el.find('#network-analysis-form').submit @onNetworkAnalysisSubmit

  onNetworkAnalysisSubmit: (e) =>
    e.preventDefault()
    @$el.find('.modal-body, .modal-footer').fadeTo(250, 0)
    @$el.find('.modal-content').addClass 'loading'
    $.ajax {
      url:  $(e.target).attr 'action'
      type: $(e.target).attr 'method'
      data: $(e.target).serialize()
      success: @onNetworkAnalysisSuccess
    }
    
  onNetworkAnalysisSuccess: (data) =>
    @$el.modal 'hide'
    @$el.find('.modal-content').removeClass 'loading'
    @$el.find('.modal-body, .modal-footer').fadeTo(0, 1)
    Backbone.trigger 'visualization.networkanalysis.success', {visualization: data.visualization, nodes: data.nodes}


module.exports = VisualizationNetworkAnalysis