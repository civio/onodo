Visualization = require './visualization.js'

$(document).ready ->

  # /visualizations/:id
  visualization = new Visualization $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize
  
  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()