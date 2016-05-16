window.App ||= {}

App.Trix = require 'script!trix'

App.VisualizationShow = require './visualization-show.js'
App.VisualizationShow = require './visualization-show.js'
App.StoryShow         = require './story-show.js'


$(document).ready ->

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()

  $body = $('body')

  # visualizations
  if $body.hasClass 'visualizations'

    # /visualizations/:id
    if $body.hasClass 'show'
      appVisualizationShow = new App.VisualizationShow $('body').data('visualization-id')
      appVisualizationShow.render()
      $( window ).resize appVisualizationShow.resize

    # /visualizations/:id/edit
    else if $body.hasClass 'edit'
      appVisualizationEdit = new App.VisualizationEdit $('body').data('visualization-id')
      appVisualizationEdit.render()
      $( window ).resize appVisualizationEdit.resize

  # stories
  else if $body.hasClass 'stories'

    # /stories/:id
    if $body.hasClass 'show'
      appStoryShow = new App.StoryShow $('body').data('visualization-id')
      appStoryShow.render()
      $( window ).resize appStoryShow.resize

    # /stories/:id/edit
    else if $body.hasClass 'edit'
      appVisualizationShow = new App.VisualizationShow $('body').data('visualization-id')
      appVisualizationShow.render()
      $( window ).resize appVisualizationShow.resize


  # Add file input feedback 
  # based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on 'change', '.btn-file :file', () ->
      label     = $(this).val().replace(/\\/g, '/').replace(/.*\//, '')
      $(this).parent().siblings('.btn-file-output').html label
