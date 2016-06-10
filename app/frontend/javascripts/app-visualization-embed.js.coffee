VisualizationEmbed = require './visualization-embed.js'

$(document).ready ->

  # /visualizations/:id/embed
  visualization = new VisualizationEmbed $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()