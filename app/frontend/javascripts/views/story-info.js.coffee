class StoryInfo extends Backbone.View

  el: '.story-info'

  initialize: ->
    # Show panel when click story-info btn
    $('.visualization-graph-menu-actions .btn-story-info').click (e) =>
      e.preventDefault()
      @$el.addClass 'active'
    # Hide panel when click close btn
    @$el.find('.close').click (e) =>
      e.preventDefault()
      @$el.removeClass 'active'
    @render()

  render: ->
    return this

module.exports = StoryInfo