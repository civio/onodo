Chapter               = require './../models/chapter.js'
Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/story-info.handlebars'

class StoryInfo extends Backbone.View

  el:             '.story-info'
  index:          null
  edit:           null
  chaptersLength: null

  initialize: (options) ->
    @edit = options.edit
    # Get chapters list length
    @chaptersLength = @$el.find('.chapters-list li').size()
    # Show panel when click story-info btn
    $('.visualization-graph-menu-actions .btn-story-info').click @onBtnStoryInfoClick
    # Hide panel when click close btn
    @$el.find('.close').click @onCloseBtnClick
    # Return to index
    @$el.find('.index-back-btn').click      @onIndexBackBtnClick
    # Listen for click on chapter-list items
    @$el.find('.chapters-list a.chapter').click     @onChaptersListClick
     # Listen for click on chapter-navigation arrows
    @$el.find('.chapter-navigation').click            @onChapterNavigationClick
    @$el.find('.chapter-navigation').children().click @onChapterNavigationChildrenClick
    @render()

  render: ->
    # Update template & render if we have a model
    if @model
      console.log 'render', @model.get('id')
      # Get chapter index
      @index = parseInt @model.get('number')
      # Compile the template using Handlebars
      template = HandlebarsTemplate {
        id:           @model.get('id')
        name:         @model.get('name')
        description:  @model.get('description')
        edit:         @edit
        #image: if @node.get('image') then @node.get('image').huge.url else null
      }
      @$el.find('.panel-body .index-content, .panel-heading .index-header').addClass 'hide'
      @$el.find('.panel-body .chapter-content, .panel-heading .chapter-header').removeClass 'hide'
      @$el.find('.panel-body .chapter-content').html template
      @$el.find('.panel-heading .chapter-header .chapter-index').html @model.get('number')
      # Show/hide prev/next arrows
      @$el.find('.chapter-navigation').removeClass 'invisible'
      if @index == 1
         @$el.find('.chapter-navigation-prev').addClass 'invisible'
      else if @index == @chaptersLength
         @$el.find('.chapter-navigation-next').addClass 'invisible'
    else
      @$el.find('.panel-body .index-content, .panel-heading .index-header').removeClass 'hide'
      @$el.find('.panel-body .chapter-content, .panel-heading .chapter-header').addClass 'hide'
    return this

  showChapter: (chapter) ->
    # Store chapter as view model & call render
    @model = chapter
    @render()

  onBtnStoryInfoClick: (e) =>
      e.preventDefault()
      @$el.addClass 'active'

  onCloseBtnClick: (e) =>
    e.preventDefault()
    @$el.removeClass 'active'

  onIndexBackBtnClick: (e) =>
    e.preventDefault()
    @model = null
    @render()

  onChaptersListClick: (e) ->
    e.preventDefault()
    Backbone.trigger 'story.info.showChapter', {id: $(this).attr('href')}

  onChapterNavigationClick: (e) =>
    e.preventDefault()
    @index = if $(e.target).hasClass('chapter-navigation-next') then @model.get('number')+1 else @model.get('number')-1
    @$el.find('.chapters-list li:nth-child('+@index+') a.chapter').trigger 'click'

  onChapterNavigationChildrenClick: (e) ->
    e.stopPropagation()
    $(this).parent().trigger 'click'

module.exports = StoryInfo