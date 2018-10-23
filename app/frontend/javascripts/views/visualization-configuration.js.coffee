Slider        = require 'bootstrap-slider'
Switch        = require 'bootstrap-switch'

class VisualizationConfiguration extends Backbone.View

  el: '.visualization-graph-panel-configuration'

  onChangeNodesColor: (e) =>
    @parameters.nodesColor = $(e.target).find('.active').data('value')
    #console.log 'onChangeNodesColor', @parameters.nodesColor
    Backbone.trigger 'visualization.config.updateNodesColor', {value: @parameters.nodesColor}
    @updateParameters()
    @updateNodesColorColumn()

  onChangeNodesColorColumn: (e) =>
    value = $(e.target).find('.active').data('value')
    if value == @parameters.nodesColorColumn
      return
    @parameters.nodesColorColumn = value
    Backbone.trigger 'visualization.config.updateNodesColorColumn', {value: @parameters.nodesColorColumn}
    @updateParameters() 
  
  onChangeNodesSize: (e) =>
    @parameters.nodesSize = parseInt $(e.target).find('.active').data('value')
    Backbone.trigger 'visualization.config.updateNodesSize', {value: @parameters.nodesSize}
    @updateParameters()
    @updateNodesSizeColumn()

  onChangeNodesSizeColumn: (e) =>
    value = $(e.target).find('.active').data('value')
    if value == @parameters.nodesSizeColumn
      return
    @parameters.nodesSizeColumn = value
    Backbone.trigger 'visualization.config.updateNodesSizeColumn', {value: @parameters.nodesSizeColumn}
    @updateParameters()

  onChangeRelationsWidth: (e) =>
    @parameters.relationsWidth = parseInt $(e.target).find('.active').data('value')
    Backbone.trigger 'visualization.config.updateRelationsWidth', {value: @parameters.relationsWidth}
    @updateParameters()
    @updateRelationsWidthColumn()

  onChangeRelationsWidthColumn: (e) =>
    value = $(e.target).find('.active').data('value')
    if value == @parameters.relationsWidthColumn
      return
    @parameters.relationsWidthColumn = value
    Backbone.trigger 'visualization.config.updateRelationsWidthColumn', {value: @parameters.relationsWidthColumn}
    @updateParameters()

  onToogleNodesLabel: (e, state) =>
    @parameters.showNodesLabel = state
    Backbone.trigger 'visualization.config.toogleNodesLabel', {value: @parameters.showNodesLabel}
    @updateParameters()

  onToogleNodesLabelComplete: (e, state) =>
    @parameters.showNodesLabelComplete = state
    Backbone.trigger 'visualization.config.toogleNodesLabelComplete', {value: @parameters.showNodesLabelComplete}
    @updateParameters()

  onToogleNodesImage: (e, state) =>
    @parameters.showNodesImage = state
    Backbone.trigger 'visualization.config.toogleNodesImage', {value: @parameters.showNodesImage}
    @updateParameters()

  onToogleShowLegend: (e, state) =>
    @parameters.showLegend = state
    Backbone.trigger 'visualization.config.toogleShowLegend', {value: @parameters.showLegend}
    @updateParameters()

  ###
  onChangeRelationsCurvature: (e) =>
    @parameters.relationsCurvature = $(e.target).val()
    Backbone.trigger 'visualization.config.updateRelationsCurvature', {value: @parameters.relationsCurvature}
  ###

  onChangeRelationsLineStyle: (e) =>
    @parameters.relationsLineStyle = parseInt $(e.target).val()
    Backbone.trigger 'visualization.config.updateRelationsLineStyle', {value: @parameters.relationsLineStyle}
    @updateParameters()

  onChangeLinkdistance: (e) =>
    @parameters.linkDistance = e.newValue
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: 'linkDistance', value: e.newValue}

  onChangeLinkstrength: (e) =>
    @parameters.linkStrength = e.newValue
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: 'linkStrength', value: e.newValue}


  onResetDefaults: (e) =>
    e.preventDefault()
    $(e.target).blur()
    # we only reset force layout params
    @parameters.linkDistance = @parametersDefault.linkDistance
    @parameters.linkStrength = @parametersDefault.linkStrength
    @setupSlidersValues()
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: 'linkDistance', value: @parameters.linkDistance}
    Backbone.trigger 'visualization.config.updateForceLayoutParam', {name: 'linkStrength', value: @parameters.linkStrength}
    @updateParameters()
  
  updateParameters: =>
    #console.log 'parameters', @parameters
    @model.save { parameters: JSON.stringify @parameters }, {patch: true}

  updateParameter: (key, value) ->
    #console.log 'updateParameter', key, value
    @parameters[key] = value
    @updateParameters()

  setupSliders: ->
    # Initialize sliders
    #@sliderCurvature    = new Slider '#curvature'
    @sliderLinkdistance = new Slider '#linkdistance'
    @sliderLinkstrength = new Slider '#linkstrength'
    # Listen to slideStop value tu sync model
    #@sliderCurvature.on    'slideStop', @updateParameters
    @sliderLinkdistance.on 'slideStop', @updateParameters
    @sliderLinkstrength.on 'slideStop', @updateParameters
    # Listen slide event to trigger visualization.config events
    #@sliderCurvature.on    'change', @onChangeRelationsCurvature
    @sliderLinkdistance.on 'change', @onChangeLinkdistance
    @sliderLinkstrength.on 'change', @onChangeLinkstrength

  setupSlidersValues: ->
    #@sliderCurvature.setValue    parseFloat(@parameters.relationsCurvature)
    @sliderLinkdistance.setValue parseFloat(@parameters.linkDistance)
    @sliderLinkstrength.setValue parseFloat(@parameters.linkStrength)

  render: (_parameters, _parametersDefault) ->
    @parameters        = _parameters
    @parametersDefault = _parametersDefault
    # Add custom field to nodes color column selector
    @setCustomFields()
    @updateNodesColorColumn()
    @updateNodesSizeColumn()
    @updateRelationsWidthColumn()

    # Setup switches
    @$el.find('#showNodesLabel').bootstrapSwitch()
    @$el.find('#showNodesLabelComplete').bootstrapSwitch()
    @$el.find('#showNodesImage').bootstrapSwitch()
    @$el.find('#showLegend').bootstrapSwitch()

    # Setup dropdown selects (nodes color, nodes color column & nodes size) & initialize it
    @$el.find('.dropdown-select .dropdown-menu li').click @onDropdownSelectChange
    @$el.find('#nodes-color .dropdown-menu li[data-value="' + @parameters.nodesColor + '"]').trigger 'click'
    @$el.find('#nodes-color-column .dropdown-menu li[data-value="' + @parameters.nodesColorColumn + '"]').trigger 'click'
    @$el.find('#nodes-size .dropdown-menu li[data-value="' + @parameters.nodesSize + '"]').trigger 'click'
    @$el.find('#relations-width .dropdown-menu li[data-value="' + @parameters.relationsWidth + '"]').trigger 'click'
    @$el.find('#relations-width-column .dropdown-menu li[data-value="' + @parameters.relationsWidthColumn + '"]').trigger 'click'
    
    # Setup relations-line-style selectors
    @$el.find('#relations-line-style').val @parameters.relationsLineStyle

    # Setup switches
    @$el.find('#showNodesLabel').bootstrapSwitch         'state', @parameters.showNodesLabel
    @$el.find('#showNodesLabelComplete').bootstrapSwitch 'state', @parameters.showNodesLabelComplete
    @$el.find('#showNodesImage').bootstrapSwitch         'state', @parameters.showNodesImage
    @$el.find('#showLegend').bootstrapSwitch             'state', @parameters.showLegend
    
    # Setup sliders
    @setupSliders()
    @setupSlidersValues()

    # Visualization Styles
    @$el.find('#nodes-color').change            @onChangeNodesColor
    @$el.find('#nodes-color-column').change     @onChangeNodesColorColumn
    @$el.find('#nodes-size').change             @onChangeNodesSize
    @$el.find('#nodes-size-column').change      @onChangeNodesSizeColumn
    @$el.find('#relations-width').change        @onChangeRelationsWidth
    @$el.find('#relations-width-column').change @onChangeRelationsWidthColumn
    @$el.find('#showNodesLabel').on             'switchChange.bootstrapSwitch', @onToogleNodesLabel
    @$el.find('#showNodesLabelComplete').on     'switchChange.bootstrapSwitch', @onToogleNodesLabelComplete
    @$el.find('#showNodesImage').on             'switchChange.bootstrapSwitch', @onToogleNodesImage
    @$el.find('#showLegend').on                 'switchChange.bootstrapSwitch', @onToogleShowLegend
    @$el.find('#relations-line-style').change @onChangeRelationsLineStyle
    # Handle reset defaults
    @$el.find('#reset-defaults').click        @onResetDefaults

    # Add new custom fields to selects when created
    @model.on 'change:node_custom_fields', @onNodesCustomFieldAdded
    @model.on 'change:relation_custom_fields', @onRelationsCustomFieldAdded

    return this

  setCustomFields: ->
    if @model.get('node_custom_fields')
      str = ''
      $nodesColorColumn = @$el.find('#nodes-color-column .dropdown-menu')
      $nodesSizeColumn = @$el.find('#nodes-size-column .dropdown-menu')
      @model.get('node_custom_fields').forEach (field) =>
        str += @getCustomFieldElement field.name
      $nodesColorColumn.append str
      $nodesSizeColumn.append str
    if @model.get('relation_custom_fields')
      str = ''
      $relationsWidthColumn = @$el.find('#relations-width-column .dropdown-menu')
      @model.get('relation_custom_fields').forEach (field) =>
        # get only numeric columns
        if field.type == 'number'
          str += @getCustomFieldElement field.name
      $relationsWidthColumn.append str

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

  onNodesCustomFieldAdded: (e) =>
    str = ''
    $nodesColorColumn = @$el.find('#nodes-color-column .dropdown-menu')
    $nodesSizeColumn = @$el.find('#nodes-size-column .dropdown-menu')
    @model.get('node_custom_fields').forEach (field) =>
      # if custom_field is not in dropdowns we have to add it
      if $nodesColorColumn.find("li[data-value='" + field.name + "']").length == 0
        # add custom_field to nodes color & nodes size selectors
        str += @getCustomFieldElement field.name
    $nodesColorColumn.append str
    $nodesSizeColumn.append str
    @resetDropdownsSelectChange()

  onRelationsCustomFieldAdded: (e) =>
    str = ''
    $relationsWidthColumn = @$el.find('#relations-width-column .dropdown-menu')
    @model.get('relation_custom_fields').forEach (field) =>
      # if custom_field is not in dropdowns and is numeric we have to add it
      if $relationsWidthColumn.find("li[data-value='" + field.name + "']").length == 0 and field.type == 'number'
        str += @getCustomFieldElement field.name  
    $relationsWidthColumn.append str
    @resetDropdownsSelectChange()

  # reset click listener for dropdown-selects
  resetDropdownsSelectChange: ->
    @$el.find('.dropdown-select .dropdown-menu li').off 'click'
    @$el.find('.dropdown-select .dropdown-menu li').click @onDropdownSelectChange


  # Update methods
  # ----------------------

  updateNodesColorColumn: ->
    if @parameters.nodesColor == 'quantitative' or @parameters.nodesColor == 'qualitative'
      @$el.find('.nodes-color-column-container').removeClass 'hide'
    else
      @$el.find('.nodes-color-column-container').addClass 'hide'

  updateNodesSizeColumn: ->
    if @parameters.nodesSize == 1
      @$el.find('.nodes-size-column-container').removeClass 'hide'
    else
      @$el.find('.nodes-size-column-container').addClass 'hide'

  updateRelationsWidthColumn: ->
    if @parameters.relationsWidth == 1
      @$el.find('.relations-width-column-container').removeClass 'hide'
    else
      @$el.find('.relations-width-column-container').addClass 'hide'


  getCustomFieldElement: (custom_field_name) ->
    return '<li data-value="'+custom_field_name+'"><p>'+custom_field_name.replace(/_+/g,' ')+'</p></li>'

module.exports = VisualizationConfiguration