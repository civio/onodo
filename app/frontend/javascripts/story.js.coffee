# Imports
Visualization = require './visualization.js'
StoryIndex    = require './views/story-index.js'

class Story

  id:   null
  edit: null

  constructor: (_id, _edit) ->
    console.log 'setup story', _id, _edit
    @id   = _id
    @edit = _edit
    # Setup Visualization Model
    @visualization = new Visualization @id, false
    # Setup Story Index
    @storyIndex = new StoryIndex
    # Setup 'Start reading' button interaction
    $('.story-cover .btn-start-reading').click (e) ->
      e.preventDefault()
      $('.story-cover').fadeOut()
      $('.visualization-info, .visualization-description').fadeIn()

  resize: =>
    @visualization.resize()

  render: ->
    # force resize
    @resize()
    # render views
    @visualization.render()
    @storyIndex.render()

module.exports = Story