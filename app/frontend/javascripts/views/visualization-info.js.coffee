Handlebars            = require 'handlebars'
HandlebarsTemplate    = require './../templates/visualization-graph-info.handlebars'

class VisualizationInfo extends Backbone.View

  el:             '.visualization-graph-info'
  node_custom_fields:  null

  show: (node, node_custom_fields) ->
    @model              = node
    @node_custom_fields = node_custom_fields
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
      # set template attributes
      templateAttr = {
        name:         @model.get('name')
        description:  @getDescription @model.get('description')
        type:         @model.get('node_type')
        image:        @getImage @model
      }
      # if available node_custom_fields, add to templateAttr.node_custom_fields object
      if @node_custom_fields and @node_custom_fields.length > 0
        templateAttr.custom_fields = []
        @node_custom_fields.forEach (field) =>
          val = @model.get(field.name)
          unless val == null or val == undefined or val == ''
            templateAttr.custom_fields.push {key: field.name.replace(/_+/g, ' '), value: val}
      # Compile the template using Handlebars
      template = HandlebarsTemplate templateAttr
      @$el.find('.panel-body').html template
    return this


  getDescription: (str) ->
    if str 
      str = str
        .replace(/<a\s+href=/gi, '<a target="_blank" href=')  # add target blank to links
        .replace(/&lt;iframe/g, '<iframe')                    # escape iframe tags
        .replace(/&lt;\/iframe&gt;/g, '</iframe>')  
    return str

  getImage: (model) ->
    # if image is defined and is an object with image.huge.url attribute get that
    if @model.get('image') and @model.get('image').huge
      @model.get('image').huge.url
    # if image is defined but is a string get the string
    else if typeof @model.get('image') == 'string'
      @model.get('image')
    else
      null

module.exports = VisualizationInfo