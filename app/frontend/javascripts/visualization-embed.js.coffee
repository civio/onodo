VisualizationBase = require './visualization-base.js'

class VisualizationEmbed extends VisualizationBase

  constructor: (_id) ->
    super _id
    document.addEventListener 'fullscreenchange', @onFullScreenChange, false
    document.addEventListener 'webkitfullscreenchange', @onFullScreenChange, false
    document.addEventListener 'mozfullscreenchange', @onFullScreenChange, false

  onFullscreen: (e) =>
    # toggle full screen
    if !document.fullscreenElement and !document.mozFullScreenElement and !document.webkitFullscreenElement
      if document.documentElement.requestFullscreen
        document.documentElement.requestFullscreen()
      else if document.documentElement.mozRequestFullScreen
        document.documentElement.mozRequestFullScreen()
      else if document.documentElement.webkitRequestFullscreen
        document.documentElement.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
    else
      if document.cancelFullScreen
        document.cancelFullScreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else if document.webkitCancelFullScreen
        document.webkitCancelFullScreen()

  onFullScreenChange: ->
    $('body').toggleClass 'fullscreen'

module.exports = VisualizationEmbed