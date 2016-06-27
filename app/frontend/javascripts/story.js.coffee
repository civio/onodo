ChaptersCollection  = require './collections/chapters-collection.js'
VisualizationStory  = require './visualization-story.js'
StoryInfo           = require './views/story-info.js'

class Story

  story_id:         null
  visualization_id: null
  chapters:         null
  visualization:    null
  storyInfo:        null
  currentChapterId: null

  constructor: (_story_id, _visualization_id) ->
    @story_id         = _story_id
    @visualization_id = _visualization_id
    # Setup Chapters Collection
    @chapters         = new ChaptersCollection()
    # Setup Visualization View
    @visualization    = new VisualizationStory @visualization_id
    # Setup Story Index
    @storyInfo        = new StoryInfo
    # Listen for chapters navigation
    Backbone.on 'story.showChapter',    @onShowChapter, @
    # Listen for visualization syncronization
    Backbone.on 'visualization.synced', @onVisualizationSynced, @
    # Event listener for Chapter delete Modal
    $('#story-chapter-delete-modal').on 'show.bs.modal', (e) =>
      # Load chapter/:id/delete template into story-chapter-delete-modal
      $('#story-chapter-delete-modal .modal-content').load '/chapters/'+@currentChapterId+'/delete/'
  
  render: ->
    # render views
    @visualization.render()

  resize: =>
    @visualization.resize()

  onVisualizationSynced: (e) ->
    # fetch collection
    @chapters.fetch {url: '/api/stories/'+@story_id+'/chapters/', success: @onChaptersSync}

  onChaptersSync: (e) =>
    # console.log 'chapters sync', @chapters
    if @chapters.length > 0
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