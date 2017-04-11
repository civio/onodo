VisualizationCanvas = require './visualization-canvas.js'

class VisualizationCanvasEdit extends VisualizationCanvas

  # Node Methods
  # ---------------

  addNode: (node) ->
    #console.log 'addNode', node
    @addNodeData node
    @render true

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
    @render true

  showNode: (node) ->
    #console.log 'show node', node
    # add node to data_nodes_visible array
    @addNodeVisibleData node
    # add node relations to data_relations_visible array
    @updateDataRelationsVisible()
    # update scale nodes size
    @setScaleNodesSize()
    @render true

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
    @render true

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


  # Relation Methods
  # ---------------

  addRelation: (relation) ->
    #console.log 'addRelation', relation
    @addRelationData relation
    @setScaleNodesSize()
    # set relation states
    @updateRelation relation
    @render true

  removeRelation: (relation) ->
    #console.log 'removeRelation', relation
    @removeRelationData relation
    @setScaleNodesSize()
    @render true

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
    @restartForce()


  # Auxiliar Methods
  # ----------------

  getNodeRelations: (id) ->
    return @data_relations_visibles.filter (d) => return d.source_id == id || d.target_id == id

  # Checkout!!! We don't use this method
  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) -> return d.source_id == node.id || d.target_id == node.id


module.exports = VisualizationCanvasEdit