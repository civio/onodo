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

    console.log 'Hola demo!', @steps

    @addPopover @steps[@current_step]

  addPopover: (step) ->
    console.log 'addPopover', @current_step

    if @current_step > 0
      $(@steps[@current_step-1].selector).popover('hide').popover('destroy')

    $(step.selector)
      .data('content', step.content)
      .data('title', step.title)
      .data('placement', step.placement)
      .data('template', @template)
      .data('container', 'body')

    $(step.selector).popover().popover('show')

    if @current_step < @steps.length-1
      console.log 'add click event'
      $('.popover-demo').one 'click', (e) =>
        console.log 'next demo step'
        @addPopover @steps[++@current_step]

module.exports = VisualizationDemo