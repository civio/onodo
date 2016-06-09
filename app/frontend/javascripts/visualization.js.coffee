VisualizationBase = require './visualization-base.js'

class Visualization extends VisualizationBase

  constructor: (_id) ->
    console.log 'Visualization'
    super _id

  resize: =>
    # setup container height
    h = if $('body').hasClass('fullscreen') then $(window).height() else $(window).height() - 178 # -50-64-64
    console.log 'resize', h
    @visualizationCanvas.$el.height h
    super()

module.exports = Visualization