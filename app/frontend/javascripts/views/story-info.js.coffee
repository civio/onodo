Chapter               = require './../models/chapter.js'
Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/story-info.handlebars'

class StoryInfo extends Backbone.View

  el: '.story-info'

  showChapter: (chapter) ->
    # Store chapter as view model & call render
    @model = chapter
    @render()

  initialize: ->
    # Show panel when click story-info btn
    $('.visualization-graph-menu-actions .btn-story-info').click (e) =>
      e.preventDefault()
      @$el.addClass 'active'
    # Hide panel when click close btn
    @$el.find('.close').click (e) =>
      e.preventDefault()
      @$el.removeClass 'active'
    # Listen for click on chapter-ist items
    @$el.find('.chapters-list a').click (e) ->
      e.preventDefault()
      Backbone.trigger 'story.info.showChapter', {id: $(this).attr('href')}
    @render()

  render: ->
    # Update template & render if we have a model
    if @model
      # Compile the template using Handlebars
      template = HandlebarsTemplate {
        name:         @model.get('name')
        description:  @model.get('description')
        #image: if @node.get('image') then @node.get('image').huge.url else null
      }
      @$el.find('.panel-body').html template
    return this

module.exports = StoryInfo