# Imports
ChaptersCollection  = require './collections/chapters-collection.js'
Visualization       = require './visualization.js'
StoryInfo           = require './views/story-info.js'

class Story

  id:             null
  edit:           null
  chapters:       null
  visualization:  null
  storyInfo:      null

  constructor: (_id, _edit) ->
    console.log 'setup story', _id, _edit
    @id   = _id
    @edit = _edit
    # Setup Chapters Collection
    @chapters       = new ChaptersCollection()
    # Setup Visualization View
    @visualization  = new Visualization @id, false
    # Setup Story Index
    @storyInfo      = new StoryInfo
    # Listen for chapters navigation
    Backbone.on 'story.info.showChapter', @onShowChapter, @
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
    # fetch collection
    @chapters.fetch {url: '/api/stories/'+@id+'/chapters/', success: @onChaptersSync}

  onChaptersSync: (e) =>
    console.log 'chapters sync', @chapters

  onShowChapter: (e) ->
    @storyInfo.showChapter  @chapters.get(e.id)

module.exports = Story