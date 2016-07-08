#VisualizationBase = require './visualization-base.js'

class VisualizationDemo

  current_step: 0
  steps:        []
  template:     '<div class="popover popover-demo" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'

  constructor:  ->
    
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
    console.log 'addPopover', @current_step

    # hide previous popup
    if @current_step > 0
      $(@steps[@current_step-1].selector).popover('hide').popover('destroy')

    # go to end-modal
    if @current_step == @steps.length-1
      $('#demo-end-modal').modal('show')
      return

    # set popover data
    $(step.selector)
      .data('content', step.content)
      .data('title', step.title)
      .data('placement', step.placement)
      .data('template', @template)
      .data('container', 'body')

    # launch popover
    $(step.selector).popover('show')

    # listen to click in popover to go to next step
    $('.popover-demo').one 'click', (e) =>
      @addPopover @steps[++@current_step]

module.exports = VisualizationDemo