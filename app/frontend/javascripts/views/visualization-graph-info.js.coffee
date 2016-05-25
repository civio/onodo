Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/visualization-graph-info.handlebars'

class VisualizationGraphInfo extends Backbone.View

  el:             '.visualization-graph-info'
  custom_fields:  null

  show: (node, custom_fields) ->
    @model         = node
    @custom_fields = custom_fields
    # Show panel if is not active
    unless @$el.hasClass 'active'
      @$el.addClass 'active'
      @$el.find('.panel-heading > a.btn').attr('href','/nodes/'+node.id+'/edit/')
    # Render template
    @render()

  hide: ->
    @$el.removeClass 'active'

  isVisible: ->
    return @$el.hasClass 'active'

  initialize: ->
    @$el.find('.close').click (e) ->
      e.preventDefault()
      Backbone.trigger 'visualization.node.hideInfo'
    @render()

  render: ->
    # Update template & render if we have a model
    if @model
      # set temaplate attributes
      templateAttr = {
        name:         @model.get('name')
        description:  @model.get('description')
        type:         @model.get('node_type')
        image:        if @model.get('image') then @model.get('image').huge.url else null
      }
      # if available custom_fields, add to templateAttr.custom_fields object
      if @custom_fields and @custom_fields.length > 0
        templateAttr.custom_fields = []
        @custom_fields.forEach (field) =>
          if @model.get(field)
            templateAttr.custom_fields.push {key: field, value: @model.get(field)}
      # Compile the template using Handlebars
      template = HandlebarsTemplate templateAttr
      @$el.find('.panel-body').html template
    return this

module.exports = VisualizationGraphInfo