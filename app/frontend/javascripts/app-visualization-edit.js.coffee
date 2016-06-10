VisualizationEdit = require './visualization-edit.js'
Trix              = require 'script!trix'

$(document).ready ->

  # /visualizations/:id/edit
  visualization = new VisualizationEdit $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize