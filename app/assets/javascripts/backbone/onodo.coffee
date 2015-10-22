#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views

window.Onodo =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
 
(($) ->

  onResizeHandler = ->
    console.log "resize", $(window).height()
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    $('.visualization-graph-container').height graphHeight
    $('.visualization-table').css 'top', graphHeight+64
    # $('.visualization-table').height( windowHeight - 64 );
    $('.footer').css 'top', graphHeight+64

  setupVisualization = ->
    onResizeHandler()
    $( window ).resize onResizeHandler
    @nodes = new Onodo.Collections.NodesCollection()
    @nodes.fetch()
    @tableView = new Onodo.Views.Nodes.TableView(collection: @nodes)
    @graphView = new Onodo.Views.Nodes.GraphView(collection: @nodes)
    #$("#nodes").html(@view.render().el)

  $(document).ready ->
    if $('body').hasClass('nodes')
      setupVisualization()

) jQuery