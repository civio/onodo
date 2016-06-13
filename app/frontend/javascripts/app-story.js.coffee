Story = require './story.js'

$(document).ready ->

  # /visualizations/:id
  story = new Story $('body').data('story-id'), $('body').data('visualization-id')
  story.render()
  $( window ).resize story.resize

  # Setup 'Start reading' button interaction
  $('.story-cover .btn-start-reading').click (e) ->
    e.preventDefault()
    $('.story-cover').fadeOut()
    $('.visualization-info, .visualization-description').fadeIn()