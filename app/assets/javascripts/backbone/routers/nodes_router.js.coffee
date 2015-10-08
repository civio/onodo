class Onodo.Routers.NodesRouter extends Backbone.Router

  initialize: (options) ->
      console.log 'router initialized'
      @nodes = new Onodo.Collections.NodesCollection()
      @nodes.fetch()
      #@nodes.reset options.nodes

  routes:
    ""           : "index"
    "nodes"      : "nodes" 
  #   "new"      : "newNode"
  #   "index"    : "index"
  #   ":id/edit" : "edit"
  #   ":id"      : "show"
  #   ".*"        : "index"

  index: ->
    console.log 'router index', @nodes 
    @view = new Onodo.Views.Nodes.IndexView(collection: @nodes)
    $("#nodes").html(@view.render().el)

  nodes: ->
    alert "welcome to onodo nodes"

  # newNode: ->
  #   @view = new Onodo.Views.Nodes.NewView(collection: @nodes)
  #   $("#nodes").html(@view.render().el)

  # index: ->
  #   @view = new Onodo.Views.Nodes.IndexView(collection: @nodes)
  #   $("#nodes").html(@view.render().el)

  # show: (id) ->
  #   node = @nodes.get(id)

  #   @view = new Onodo.Views.Nodes.ShowView(model: node)
  #   $("#nodes").html(@view.render().el)

  # edit: (id) ->
  #   node = @nodes.get(id)

  #   @view = new Onodo.Views.Nodes.EditView(model: node)
  #   $("#nodes").html(@view.render().el)
