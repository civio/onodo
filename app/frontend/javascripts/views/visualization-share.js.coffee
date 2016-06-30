class VisualizationShare extends Backbone.View

  el: '#visualization-share'
  
  initialize: ->
    @render()

  render: -> 
    @$el.find('.embed-form').submit (e) ->
      e.preventDefault()
    # update hide title
    @$el.find('.embed-form .checkbox input').change (e) =>
      str = @$el.find('#embed-code').val()
      title = if $(e.target).prop('checked') then '' else '?notitle'
      str = str.replace(/src="(.*)(embed\/|embed\/\?notitle)"/, 'src="$1embed/'+title+'"')
      @$el.find('#embed-code').val( str )
    # update embed height
    @$el.find('.embed-form #embed-height').change (e) =>
      str = @$el.find('#embed-code').val()
      str = str.replace(/ height="(\d*)?px"/, ' height="'+$(e.target).val()+'px"')
      @$el.find('#embed-code').val( str )
    return this

module.exports = VisualizationShare