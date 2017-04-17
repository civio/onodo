d3 = require '../dist/d3'
VisualizationCanvas = require './visualization-canvas.js'

class VisualizationCanvasEdit extends VisualizationCanvas

  # clear all nodes & relations (needed for app-visualization-demo)
  clear: ->
    # hide canvas
    @canvas.style 'display', ''
    # add loading class
    @$el.addClass 'loading'


  # Node Methods
  # ---------------

  addNode: (node) ->
    #console.log 'addNode', node
    @addNodeData node
    @render 0.15

  removeNode: (node) ->
    # unfocus node to remove
    if @node_active == node.id
      @unfocusNode()
    # remove node
    @removeNodeData node
    # remove node relations
    @removeNodeRelations node
    # update scale nodes size
    @setScaleNodesSize()
    @render 0.15

  showNode: (node) ->
    #console.log 'show node', node
    # add node to data_nodes_visible array
    @addNodeVisibleData node
    # add node relations to data_relations_visible array
    @updateDataRelationsVisible()
    # update scale nodes size
    @setScaleNodesSize()
    @render 0.15

  hideNode: (node) ->
    # unfocus node to remove
    if @node_active == node.id
      @unfocusNode()
    # remove node from data:nodes_visible array
    @removeNodeVisibleData node
    # remove node relations from data_relations_visible array
    @updateDataRelationsVisible()
    # update scale nodes size
    @setScaleNodesSize()
    @render 0.15

  addNodeVisibleData: (node) =>
    @data_nodes_visibles.push node

  removeNodeData: (node) ->
    # We can't use Array.splice because this function could be called inside a loop over nodes & causes drop -> CHECKOUT!!!
    @data_nodes = @data_nodes.filter (d) -> return d.id != node.id
    if node.visible
      @removeNodeVisibleData node

  removeNodeVisibleData: (node) ->
    @data_nodes_visibles = @data_nodes_visibles.filter (d) -> return d.id != node.id

  removeNodeRelations: (node) =>
    # remove relations with removed node in data_relations & data_relations_visibles arrays
    @data_relations = @data_relations.filter (d) -> return d.source_id != node.id and d.target_id != node.id
    @updateDataRelationsVisible()

  updateNodeLabel: (node) ->
    node = @getNodeById node.id
    if node
      @setNodeLabel node
      @redraw()

  updateNodeImage: (node) ->
    node = @getNodeById node.id
    if node
      @setNodeImage node, @redraw

  fixNodes: ->
    # store current nodes position
    data = []
    @data_nodes_visibles.forEach (node) =>
      model = @nodes_collection.get node
      #TODO!!! -> create an API endpoint to update position of all nodes in a visualization
      ###
      data.push {
        id: node.id
        x: node.x|0
        y: node.y|0
      }
      ###
      model.save {
          posx: node.x
          posy: node.y
        }, true
    #console.log JSON.stringify(data)
    @render()

  unfixNodes: ->
    # center node before call to render in visualization-edit onFixNodes method
    @data_nodes_visibles.forEach (node) ->
      # reset node position & velocity
      node.x = node.vx = NaN
      node.y = node.vy = NaN
      # remove fixed positions
      node.fx = null
      node.fy = null
    @render 1
    

  # Relation Methods
  # ---------------

  addRelation: (relation) ->
    #console.log 'addRelation', relation
    @addRelationData relation
    @setScaleNodesSize()
    # set relation states
    @updateRelation relation
    @render 0.15

  removeRelation: (relation) ->
    #console.log 'removeRelation', relation
    @removeRelationData relation
    @setScaleNodesSize()
    @render 0.15

   # maybe we need to split removeVisibleRelationaData & removeRelationData
  removeRelationData: (relation) =>
    # remove relation from data_relations
    #console.log 'remove relation from data_relations', @data_relations
    index = @data_relations.indexOf relation
    #console.log 'index', index
    if index != -1
      @data_relations.splice index, 1
    @updateDataRelationsVisible()

  updateRelationNode: (relation) ->
    # remove relation data
    @removeRelationData relation
    # add again updated relation
    @addRelation relation

  # update data_relations_visibles filtering data_relations array
  updateDataRelationsVisible: ->
    @data_relations_visibles = @data_relations.filter (d) -> d.source and d.target and d.source.visible and d.target.visible
  
  updateRelationsLabelsData: (relation) ->
    # redraw only if relation source or target are an active node
    if @node_active and (@node_active.id == relation.source_id or @node_active.id == relation.target_id)
      @redraw()


  # Config Methods
  # ---------------
    
  updateNodesColor: (value) =>
    @parameters.nodesColor = value
    @updateNodesColorValue()

  updateNodesColorColumn: (value) =>
    @updateNodesColorValue()

  updateNodesColorValue: =>
    @setColorScale()
    @data_nodes_visibles.forEach (d) =>
      @setNodeFill d
      @setNodeStroke d
    @redraw()

  updateNodesSize: (value) =>
    @parameters.nodesSize = +value
    @updateNodesSizeValue()
    
  updateNodesSizeColumn: (value) =>
    @updateNodesSizeValue()

  updateNodesSizeValue: ->
    @setScaleNodesSize()
    @data_nodes_visibles.forEach (d) =>
      @setNodeSize d
    @redraw()

  toogleNodesImage: (value) =>
    @parameters.showNodesImage = value
    @data_nodes_visibles.forEach (d) =>
      @setNodeImage d
    @redraw()
  
  ###
  toogleNodesWithoutRelation: (value) =>
    if value
      @data_nodes_visibles.forEach (d) =>
        if !@hasNodeRelations(d)
          @removeNode d
    else
      # TODO!!! Check visibility before add a node
      @data_nodes_visibles.forEach (d) =>
        if !@hasNodeRelations(d)
          @addNode d
    @render()

  updateRelationsCurvature: (value) ->
    @parameters.relationsCurvature = value
    @redraw()
  ###

  updateForceLayoutParameter: (param, value) ->
    #console.log 'updateForceLayoutParameter', param, value
    #@force.stop()
    if param == 'linkDistance'
      @forceLink.distance () -> return value
      @force.force 'link', @forceLink
    else if param == 'linkStrength'
      @forceManyBody.strength () -> return value
      @force.force 'charge', @forceManyBody
    # else if param == 'friction'
    #   @force.friction value
    # else if param == 'charge'
    #   @force.charge value
    # else if param == 'theta'
    #   @force.theta value
    # else if param == 'gravity'
    #  @force.gravity value
    @restartForce 0.15


  # Mouse Events Listeners
  # -------------------

  # STORE NODES POSITION
  onCanvasDragEnd: =>
    if @node_hovered
      if !@parameters.nodesFixed
        @force.alphaTarget 0
      else
        # get node hovered as Node model
        node = @nodes_collection.get @node_hovered
        # save xpos & ypos in node model
        node.save {
            'posx': @node_hovered.x
            'posy': @node_hovered.y
          }, true
    else
      @canvas.style 'cursor','default'
      # Skip if viewport has no translation
      if @viewport.dx == 0 and @viewport.dy == 0
        Backbone.trigger 'visualization.node.hideInfo'
        return
      # TODO! Add viewportMove action to history
      @viewport.dx = @viewport.dy = 0;


  # Auxiliar Methods
  # ----------------

  getNodeRelations: (id) ->
    return @data_relations_visibles.filter (d) => return d.source_id == id || d.target_id == id

  # Checkout!!! We don't use this method
  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) -> return d.source_id == node.id || d.target_id == node.id


module.exports = VisualizationCanvasEdit