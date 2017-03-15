VisualizationEdit = require './visualization-edit.js'
Trix              = require 'script-loader!trix'

$(document).ready ->

  # /visualizations/:id/edit
  visualization = new VisualizationEdit $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize