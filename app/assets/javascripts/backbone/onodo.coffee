#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Onodo =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  init: ->
    new Onodo.Routers.NodesRouter()
    Backbone.history.start()

$(document).ready ->
  Onodo.init()