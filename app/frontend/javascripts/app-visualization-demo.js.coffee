VisualizationEdit = require './visualization-edit.js'
VisualizationDemo = require './visualization-demo.js'
Trix              = require 'script!trix'

$(document).ready ->

  # /visualizations/:id/edit
  visualization = new VisualizationEdit $('body').data('visualization-id')
  visualization.render()
  $( window ).resize visualization.resize

  # wait until visualization synced to create demo
  Backbone.once 'visualization.synced', =>

    demo = new VisualizationDemo visualization.nodes, visualization.relations

    # listen to loadData event to update new data
    Backbone.once 'visualization.demo.loadData', =>
      visualization.updateData()
      Backbone.once 'visualization.synced', =>
        demo.addNextPopover()
