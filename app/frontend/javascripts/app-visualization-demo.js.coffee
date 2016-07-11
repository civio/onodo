VisualizationEdit = require './visualization-edit.js'
VisualizationDemo = require './visualization-demo.js'
Trix              = require 'script!trix'

$(document).ready ->

  # /visualizations/:id/edit
  visualization = new VisualizationEdit $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize

  demo = new VisualizationDemo visualization.nodes, visualization.relations