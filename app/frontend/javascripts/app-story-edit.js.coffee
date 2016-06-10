StoryEdit = require './story-edit.js'

$(document).ready ->

  # /visualizations/:id
  story = new StoryEdit $('body').data('story-id'), $('body').data('visualization-id')
  story.render()
  $( window ).resize story.resize