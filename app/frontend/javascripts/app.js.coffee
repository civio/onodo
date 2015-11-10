window.App ||= {}

App.VisualizationEdit = require './visualization-edit.js'

$(document).on "page:change", ->
  # /visualizations
  if $("body.visualizations.show").length > 0
    appVisualizationEdit = new App.VisualizationEdit
    appVisualizationEdit.render()
    $( window ).resize appVisualizationEdit.resize