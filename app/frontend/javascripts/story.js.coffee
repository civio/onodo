# Imports
ChaptersCollection  = require './collections/chapters-collection.js'
Visualization       = require './visualization.js'
StoryInfo           = require './views/story-info.js'

class Story

  story_id:         null
  visualization_id: null
  edit:             null
  chapters:         null
  visualization:    null
  storyInfo:        null
  currentChapterId: null

  constructor: (_story_id, _visualization_id, _edit) ->
    @story_id         = _story_id
    @visualization_id = _visualization_id
    @edit             = _edit
    # Setup Chapters Collection
    @chapters         = new ChaptersCollection()
    # Setup Visualization View
    @visualization    = new Visualization @visualization_id, @edit, true
    # Setup Story Index
    @storyInfo        = new StoryInfo {edit: @edit}
    # Listen for chapters navigation
    Backbone.on 'story.showChapter',    @onShowChapter, @
    # Listen for visualization syncronization
    Backbone.on 'visualization.synced', @onVisualizationSynced, @
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
  
  render: ->
    console.log '!!!render story', @story_id
    # render views
    @visualization.render()

  resize: =>
    @visualization.resize()

  onVisualizationSynced: (e) ->
    # fetch collection
    @chapters.fetch {url: '/api/stories/'+@story_id+'/chapters/', success: @onChaptersSync}

  onChaptersSync: (e) =>
    console.log 'chapters sync', @chapters, @edit, @chapters.length
    if !@edit and @chapters.length > 0
      Backbone.trigger 'story.showChapter', {id: @chapters.at(0).id}

  onShowChapter: (e) =>
    # Get current chapter
    chapter = @chapters.get(e.id)
    @storyInfo.showChapter chapter
    # Avoid redundancy in Visualization showChapter
    if @currentChapterId != e.id
      @currentChapterId = e.id
      @visualization.showChapter chapter.get('node_ids'), chapter.get('relation_ids')

module.exports = Story