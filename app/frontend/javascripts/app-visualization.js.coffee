Visualization = require './visualization.js'

$(document).ready ->

  # /visualizations/:id
  appVisualization = new Visualization $('body').data('visualization-id')
  appVisualization.render()
  $( window ).resize appVisualization.resize
  
  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()