window.App ||= {}

App.Trix = require 'script!trix'

App.Visualization     = require './visualization.js'
App.StoryShow         = require './story-show.js'


$(document).ready ->

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()

  $body = $('body')

  # visualizations
  if $body.hasClass 'visualizations'
    # /visualizations/:id
    # /visualizations/:id/edit
    appVisualization = new App.Visualization $('body').data('visualization-id'), $body.hasClass('edit')
    appVisualization.render()
    $( window ).resize appVisualization.resize
  # stories
  else if $body.hasClass 'stories'
    # /stories/:id
    if $body.hasClass 'show'
      appStoryShow = new App.StoryShow $('body').data('visualization-id')
      appStoryShow.render()
      $( window ).resize appStoryShow.resize
    # /stories/:id/edit
    else if $body.hasClass 'edit'
      appVisualization = new App.Visualization $('body').data('visualization-id'), $body.hasClass('edit')
      appVisualization.render()
      $( window ).resize appVisualization.resize


  # Add file input feedback 
  # based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on 'change', '.btn-file :file', () ->
      label     = $(this).val().replace(/\\/g, '/').replace(/.*\//, '')
      $(this).parent().siblings('.btn-file-output').html label
