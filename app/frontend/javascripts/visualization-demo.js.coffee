#VisualizationBase = require './visualization-base.js'

class VisualizationDemo

  current_step: 0
  steps:        []
  template:     '<div class="popover popover-demo" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'

  constructor: (_nodes, _relations) ->
    @nodes     = _nodes
    @relations = _relations
    
    # setup steps based on #demo-steps list
    $('#demo-steps li').each (index, element) =>
      $el = $(element)
      @steps.push {
        selector:  $el.data('selector')
        placement: $el.data('placement')
        title:     $el.data('title')
        content:   $el.html()
      }

    # show intro modal & wait until hidden to add popover 
    $('#demo-intro-modal').modal('show').on('hidden.bs.modal', =>
      @addPopover @steps[@current_step]
    )

  addPopover: (step) ->

    # hide previous popup
    if @current_step > 0
      $(@steps[@current_step-1].selector).popover('hide').popover('destroy')

    # go to end-modal
    if @current_step == @steps.length
      $('#demo-end-modal').modal('show')
      return

    # set popover data
    $(step.selector)
      .data('content', step.content)
      .data('title', step.title)
      .data('placement', step.placement)
      .data('template', @template)
      .data('container', 'body')
      .data('html', true)

    # launch popover
    setTimeout =>
      $(step.selector).popover('show')
      @setPopoverCallback()
    , 600

  setPopoverCallback: ->
    if @current_step == 0
      $(window).one 'scroll', =>
        @addNextPopover()
    else if @current_step == 1 || @current_step == 4
      $('#visualization-add-node-btn').one 'click', =>
        @addNextPopover()
    else if @current_step == 2
      $('.popover-demo .popover-content a').click (e) =>
        e.preventDefault()
        @addNextPopover()
    else if @current_step == 3 || @current_step == 5
      @nodes.once 'change:name', =>
        @addNextPopover()
    else if @current_step == 6
      $('.visualization-table .visualization-table-header a[href="#relations"]').one 'click', =>
        @addNextPopover()
    else if @current_step == 7
      $('#visualization-add-relation-btn').one 'click', =>
        @addNextPopover()
    else if @current_step == 8
      @relations.once 'change:source_id', =>
        @addNextPopover()
    else if @current_step == 9
      @relations.once 'change:target_id', =>
        @addNextPopover()
    else if @current_step == 10
       @relations.once 'change:relation_type', =>
        @addNextPopover()
    else if @current_step == 11
      $('.visualization-table .visualization-table-header a[href="#nodes"]').one 'click', =>
        @addNextPopover()
    else if @current_step == 12
      @nodes.once 'change:description', =>
        @addNextPopover()
    else if @current_step == 13
      $('.visualization-graph-component .nodes-cont .node').one 'click', =>
        @addNextPopover()
    else if @current_step == 14
      @nodes.once 'change:node_type', =>
        @addNextPopover()
    else if @current_step == 15
      $('.popover-demo .popover-content a').click (e) =>
        e.preventDefault()
        $(@steps[@current_step].selector).popover('hide').popover('destroy')
        Backbone.trigger 'visualization.demo.loadData'
    else if @current_step == 16
      $('.visualization-graph-menu-actions .btn-configure').click (e) =>
        @addNextPopover()
    else if @current_step == 17
      Backbone.once 'visualization.config.updateNodesSize', =>
        @addNextPopover()

  addNextPopover: ->
    @addPopover @steps[++@current_step]

module.exports = VisualizationDemo