window.App ||= {}

App.VisualizationShow = require './visualization-show.js'
App.VisualizationEdit = require './visualization-edit.js'

$(document).ready ->

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()

  # /visualizations/:id/edit
  if $('body.visualizations.edit').length > 0
    appVisualizationEdit = new App.VisualizationEdit $('body').data('id')
    appVisualizationEdit.render()
    $( window ).resize appVisualizationEdit.resize
  # /visualizations/:id
  else if $('body.visualizations.show').length > 0
    appVisualizationShow = new App.VisualizationShow $('body').data('id')
    appVisualizationShow.render()
    $( window ).resize appVisualizationShow.resize
   