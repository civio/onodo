VisualizationEdit = require './visualization-edit.js'
Trix              = require 'script!trix'

$(document).ready ->

  # /visualizations/:id/edit
  appVisualization = new VisualizationEdit $('body').data('visualization-id')
  appVisualization.render()
  $( window ).resize appVisualization.resize
  
  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()