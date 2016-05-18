window.App ||= {}

App.Visualization = require './visualization.js'
App.Story         = require './story.js'
App.Trix          = require 'script!trix'

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
    # /stories/:id/edit
    appStory = new App.Story $('body').data('story-id'), $('body').data('visualization-id'), $body.hasClass('edit')
    appStory.render()
    $( window ).resize appStory.resize

  # Add file input feedback 
  # based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on 'change', '.btn-file :file', () ->
      label     = $(this).val().replace(/\\/g, '/').replace(/.*\//, '')
      $(this).parent().siblings('.btn-file-output').html label
