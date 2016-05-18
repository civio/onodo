# Imports
ChaptersCollection  = require './collections/chapters-collection.js'
Visualization       = require './visualization.js'
StoryInfo           = require './views/story-info.js'

class Story

  id:               null
  edit:             null
  chapters:         null
  visualization:    null
  storyInfo:        null
  currentChapterId: null

  constructor: (_id, _edit) ->
    @id   = _id
    @edit = _edit
    # Setup Chapters Collection
    @chapters       = new ChaptersCollection()
    # Setup Visualization View
    @visualization  = new Visualization @id, false
    # Setup Story Index
    @storyInfo      = new StoryInfo {edit: @edit}
    # Listen for chapters navigation
    Backbone.on 'story.info.showChapter', @onShowChapter, @
    # Setup 'Start reading' button interaction
    $('.story-cover .btn-start-reading').click (e) ->
      e.preventDefault()
      $('.story-cover').fadeOut()
      $('.visualization-info, .visualization-description').fadeIn()
    # Event listener for Chapter delete Modal
    #$('#story-chapter-delete-modal').on 'show.bs.modal', (e) ->
    #  console.log 'on story chapter delete modal'
    #  $('#story-chapter-delete-modal .modal-body').load '/nodes/1/edit/description/', () =>
    #
    # Listen on click delete btn
    # Load chapters/delete/templates into #story-chapter-delete-modal
    # Show #story-chapter-delete-modal

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
    # Get current chapter
    chapter = @chapters.get(e.id)
    @storyInfo.showChapter chapter
    # Avoid redundancy in Visualization showChapter
    if @currentChapterId != e.id
      @currentChapterId = e.id
      @visualization.showChapter chapter.get('node_ids'), chapter.get('relation_ids')

module.exports = Story