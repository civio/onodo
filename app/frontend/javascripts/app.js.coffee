window.App ||= {}

App.Trix = require 'script!trix'

App.VisualizationShow = require './visualization-show.js'
App.VisualizationEdit = require './visualization-edit.js'


$(document).ready ->

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()

  # /visualizations/:id/edit
  if $('body.visualizations.edit').length > 0
    appVisualizationEdit = new App.VisualizationEdit $('body').data('visualization-id')
    appVisualizationEdit.render()
    $( window ).resize appVisualizationEdit.resize

  # /visualizations/:id
  else if $('body.visualizations.show').length > 0
    appVisualizationShow = new App.VisualizationShow $('body').data('visualization-id')
    appVisualizationShow.render()
    $( window ).resize appVisualizationShow.resize

  # /stories/:id
  else if $('body.stories.show').length > 0
    appVisualizationShow = new App.VisualizationShow $('body').data('visualization-id')
    appVisualizationShow.render()
    $( window ).resize appVisualizationShow.resize
    # Setup 'Start reading' button interaction
    $('.story-cover .btn-start-reading').click (e) ->
      e.preventDefault()
      $('.story-cover').fadeOut()
      $('.visualization-info').fadeIn()


  # Add file input feedback 
  # based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on 'change', '.btn-file :file', () ->
      label     = $(this).val().replace(/\\/g, '/').replace(/.*\//, '')
      $(this).parent().siblings('.btn-file-output').html label
