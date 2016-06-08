BootstrapSwitch = require 'bootstrap-switch'

class VisualizationConfiguration extends Backbone.View

  el: '.visualization-graph-panel-configuration'
  
  parameters: null
  parametersDefault: {
    nodesColor:         'solid-1'
    nodesColorColumn:   'type'
    nodesSize:          11
    showNodesLabel:     1
    showNodesImage:     1
    relationsCurvature: 1
    relationsLineStyle: 0
    linkDistance:       100
    linkStrength:       -30
    friction:           0.9
    charge:             -150
    theta:              0.8
    gravity:            0.1
  }

  onChangeValue: (e) =>
    key = $(e.target).attr('name')
    value = $(e.target).val()
    @parameters[ key ] = value
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: key, value: value}

  onChangeNodesColor: (e) =>
    @parameters.nodesColor = $(e.target).find('.active').data('value')
    #console.log 'onChangeNodesColor', @parameters.nodesColor
    Backbone.trigger 'visualization.config.updateNodesColor', {value: @parameters.nodesColor}
    @updateParameters()
    @updateNodesColorColumn()

  updateNodesColorColumn: ->
    if @parameters.nodesColor == 'quantitative' or @parameters.nodesColor == 'qualitative'
        @$el.find('.nodes-color-column-container').removeClass 'hide'
    else
        @$el.find('.nodes-color-column-container').addClass 'hide'

  onChangeNodesColorColumn: (e) =>
    @parameters.nodesColorColumn = $(e.target).find('.active').data('value')
    #console.log 'onChangeNodesColorColumn', @parameters.nodesColorColumn
    Backbone.trigger 'visualization.config.updateNodesColorColumn', {value: @parameters.nodesColorColumn}
    @updateParameters() 
  
  onChangeNodesSize: (e) =>
    @parameters.nodesSize = parseInt $(e.target).find('.active').data('value')
    #console.log 'onChangeNodesSize', @parameters.nodesSize
    Backbone.trigger 'visualization.config.updateNodesSize', {value: @parameters.nodesSize}
    @updateParameters()

  onToogleNodesLabel: (e, state) =>
    @parameters.showNodesLabel = state
    #console.log 'onToogleNodesLabel', @parameters.showNodesLabel
    Backbone.trigger 'visualization.config.toogleNodesLabel', {value: @parameters.showNodesLabel}
    @updateParameters()

  onToogleNodesImage: (e, state) =>
    @parameters.showNodesImage = state
    #console.log 'onToogleNodesImage', @parameters.showNodesImage
    Backbone.trigger 'visualization.config.toogleNodesImage', {value: @parameters.showNodesImage}
    @updateParameters()

  onChangeRelationsCurvature: (e) =>
    @parameters.relationsCurvature = $(e.target).val()
    Backbone.trigger 'visualization.config.updateRelationsCurvature', {value: @parameters.relationsCurvature}

  onChangeRelationsLineStyle: (e) =>
    @parameters.relationsLineStyle = parseInt $(e.target).val()
    Backbone.trigger 'visualization.config.updateRelationsLineStyle', {value: @parameters.relationsLineStyle}
    @updateParameters()

  onUpdateVisualizationParemeters: (e) =>
    # we update parameters from bootstrap-slider only when slideStop event is triggeres
    # in order to avoid redundancy
    @updateParameters()

  onResetDefaults: (e) =>
    e.preventDefault()
    $(e.target).blur()
    # we only reset force layout params
    @parameters.linkDistance        = @parametersDefault.linkDistance
    @parameters.linkStrength        = @parametersDefault.linkStrength
    @parameters.friction            = @parametersDefault.friction
    @parameters.charge              = @parametersDefault.charge
    @parameters.theta               = @parametersDefault.theta
    @parameters.gravity             = @parametersDefault.gravity
    @setupSlidersValues()
    @updateParameters()

  setupParameters: ->
    @parameters = @parameters || {}
    # setup parameters
    @parameters.nodesColor          = @parameters.nodesColor || @parametersDefault.nodesColor
    @parameters.nodesColorColumn    = @parameters.nodesColorColumn || @parametersDefault.nodesColorColumn
    @parameters.nodesSize           = @parameters.nodesSize || @parametersDefault.nodesSize
    @parameters.showNodesLabel      = if typeof @parameters.showNodesLabel != 'undefined' then @parameters.showNodesLabel else @parametersDefault.showNodesLabel
    @parameters.showNodesImage      = if typeof @parameters.showNodesImage != 'undefined' then @parameters.showNodesImage else @parametersDefault.showNodesImage
    @parameters.relationsCurvature  = @parameters.relationsCurvature || @parametersDefault.relationsCurvature
    @parameters.relationsLineStyle  = @parameters.relationsLineStyle || @parametersDefault.relationsLineStyle
    @parameters.linkDistance        = @parameters.linkDistance || @parametersDefault.linkDistance
    @parameters.linkStrength        = @parameters.linkStrength || @parametersDefault.linkStrength
    @parameters.friction            = @parameters.friction || @parametersDefault.friction
    @parameters.charge              = @parameters.charge || @parametersDefault.charge
    @parameters.theta               = @parameters.theta || @parametersDefault.theta
    @parameters.gravity             = @parameters.gravity || @parametersDefault.gravity

  updateParameters: ->
    @model.save { parameters: JSON.stringify @parameters }, {patch: true}

  setupSlidersValues: ->
    @$el.find('#curvature').slider    'setValue', parseFloat @parameters.relationsCurvature
    @$el.find('#linkdistance').slider 'setValue', parseFloat @parameters.linkDistance
    @$el.find('#linkstrength').slider 'setValue', parseFloat @parameters.linkStrength
    @$el.find('#friction').slider     'setValue', parseFloat @parameters.friction
    @$el.find('#charge').slider       'setValue', parseFloat @parameters.charge
    @$el.find('#theta').slider        'setValue', parseFloat @parameters.theta
    @$el.find('#gravity').slider      'setValue', parseFloat @parameters.gravity

  render: ->
    # Get parameters from model as JSON & setup
    @parameters = $.parseJSON @model.get('parameters')
    @setupParameters()

    # Add custom field to nodes color column selector
    @setCustomFields()
    @updateNodesColorColumn()

    # Setup switches
    @$el.find('#showNodesLabel').bootstrapSwitch()
    @$el.find('#showNodesImage').bootstrapSwitch()

    # Setup dropdown selects (nodes color, nodes color column & nodes size) & initialize it
    @$el.find('.dropdown-select .dropdown-menu li').click @onDropdownSelectChange
    @$el.find('#nodes-color .dropdown-menu li[data-value="' + @parameters.nodesColor + '"]').trigger 'click'
    @$el.find('#nodes-color-column .dropdown-menu li[data-value="' + @parameters.nodesColorColumn + '"]').trigger 'click'
    @$el.find('#nodes-size .dropdown-menu li[data-value="' + @parameters.nodesSize + '"]').trigger 'click'
    
    # Setup relations-line-style selectors
    @$el.find('#relations-line-style').val @parameters.relationsLineStyle

    # Setup switches
    @$el.find('#showNodesLabel').bootstrapSwitch 'state', @parameters.showNodesLabel
    @$el.find('#showNodesImage').bootstrapSwitch 'state', @parameters.showNodesImage
    
    # Setup sliders
    $sliders = @$el.find('.slider')
    $sliders.slider()
    $sliders.on 'slideStop', @onUpdateVisualizationParemeters
    @setupSlidersValues()

    # Visualization Styles
    @$el.find('#nodes-color').change          @onChangeNodesColor
    @$el.find('#nodes-color-column').change   @onChangeNodesColorColumn
    @$el.find('#nodes-size').change           @onChangeNodesSize
    @$el.find('#showNodesLabel').on           'switchChange.bootstrapSwitch', @onToogleNodesLabel
    @$el.find('#showNodesImage').on           'switchChange.bootstrapSwitch', @onToogleNodesImage
    @$el.find('#curvature').change            @onChangeRelationsCurvature
    @$el.find('#relations-line-style').change @onChangeRelationsLineStyle
    # Force Layout Parameters
    @$el.find('#linkdistance').change         @onChangeValue
    @$el.find('#linkstrength').change         @onChangeValue
    @$el.find('#friction').change             @onChangeValue
    @$el.find('#charge').change               @onChangeValue
    @$el.find('#theta').change                @onChangeValue
    @$el.find('#gravity').change              @onChangeValue
    # Handle reset defaults
    @$el.find('#reset-defaults').click        @onResetDefaults

    # Add new custom fields to nodes-color-column select when created
    @model.on 'change:custom_fields', @onCustomFieldAdded

    return this

  setCustomFields: ->
    if @model.get('custom_fields')
      $nodesColorColumn = $('#nodes-color-column .dropdown-menu')
      @model.get('custom_fields').forEach (field) ->
        $nodesColorColumn.append '<li data-value="'+field+'"><p>'+field.replace(/_+/g,' ')+'</p></li>'

  onDropdownSelectChange: (e) ->
    #console.log 'onDropdownSelectChange', e
    if $(this).data('value') == undefined 
      return
    # clear active element
    $(this).parent().find('.active').removeClass 'active'
    $(this).addClass 'active'
    # add clicked element as dropdown-select label
    if $(this).hasClass 'color'
      $(this).parent().parent().parent().parent().find('.dropdown-toggle .text').html $(this).parent().parent().find('p').html()
    else
      $(this).parent().parent().find('.dropdown-toggle .text').html $(this).find('p').html()
    # trigger change event on dropdown-select
    $(this).parent().parent().trigger 'change'

  onCustomFieldAdded: (e) =>
    field = @model.get('custom_fields').slice(-1)[0]
    $el = $('<li data-value="'+field+'"><p>'+field.replace(/_+/g,' ')+'</p></li>')
    $el.click @onDropdownSelectChange
    $('#nodes-color-column .dropdown-menu').append $el

module.exports = VisualizationConfiguration