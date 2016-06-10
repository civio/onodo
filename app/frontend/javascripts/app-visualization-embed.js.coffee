VisualizationEmbed = require './visualization-embed.js'

$(document).ready ->

  # /visualizations/:id/embed
  appVisualization = new VisualizationEmbed $('body').data('visualization-id')
  appVisualization.render()
  $( window ).resize appVisualization.resize

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()