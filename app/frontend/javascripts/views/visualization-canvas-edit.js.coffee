VisualizationCanvas = require './visualization-canvas.js'

class VisualizationCanvasEdit extends VisualizationCanvas

  # Node Methods
  # ---------------

  removeNodeData: (node) ->
    @data_nodes_map.remove node.id
    # We can't use Array.splice because this function could be called inside a loop over nodes & causes drop
    @data_nodes = @data_nodes.filter (d) =>
      return d.id != node.id

  addNode: (node) ->
    #console.log 'addNode', node
    console.log 'addNode', node
    @addNodeData node
    @render true
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    # unfocus node to remove
    if @node_active == node.id
      @unfocusNode()
    @removeNodeData node
    @removeNodeRelations node
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @render true

  removeNodeRelations: (node) =>
    # update data_relations_visibles removing relations with removed node
    @data_relations_visibles = @data_relations_visibles.filter (d) =>
      return d.source_id != node.id and d.target_id != node.id

  showNode: (node) ->
    #console.log 'show node', node
    # add node to data_nodes array
    @addNodeData node
    # check node relations (in data.relations)
    @data_relations.forEach (relation) =>
      # if node is present in some relation we add it to data_relations and/or data_relations_visibles array
      if relation.source_id  == node.id or relation.target_id == node.id
        @addRelationData relation
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @render true

  hideNode: (node) ->
    @removeNode node

  updateNodeLabel: (node) ->
    node = @getNodeById node.id
    if node
      @setNodeLabel node
      @redraw()

  updateNodeImage: (node) ->
    node = @getNodeById node.id
    if node
      @setNodeImage node
      @redraw()


  # Relation Methods
  # ---------------

  addRelationData: (relation) ->
    # We have to add relations to @data.relations which stores all the relations
    index = @data_relations.indexOf relation
    #console.log 'addRelationData', index
    # Set source & target as nodes objetcs instead of index number --> !!! We need this???
    relation.source  = @getNodeById relation.source_id
    relation.target  = @getNodeById relation.target_id
    # Add relations to data_relations array if not present yet
    if index == -1
      @data_relations.push relation
    # Add relation to data_relations_visibles array if both nodes exist and are visibles
    if relation.source and relation.target and relation.source.visible and relation.target.visible
      @data_relations_visibles.push relation
      @addRelationToLinkedByIndex relation.source_id, relation.target_id
      #@setLinkIndex()

  # maybe we need to split removeVisibleRelationaData & removeRelationData
  removeRelationData: (relation) =>
    # remove relation from data_relations
    #console.log 'remove relation from data_relations', @data_relations
    index = @data_relations.indexOf relation
    #console.log 'index', index
    if index != -1
      @data_relations.splice index, 1
    @removeVisibleRelationData relation

  addRelation: (relation) ->
    #console.log 'addRelation', relation
    @addRelationData relation
    # update nodes relations size if needed to take into acount the added relation
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @updateRelation relation
    @redraw()

  removeRelation: (relation) ->
    #console.log 'removeRelation', relation
    @removeRelationData relation
    @updateRelationsLabelsData()
    # update nodes relations size if needed to take into acount the removed relation
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @redraw()

  removeVisibleRelationData: (relation) =>
    #console.log 'remove relation from data_relations_visibles', @data_relations_visibles
    # remove relation from data_relations_visibles
    index = @data_relations_visibles.indexOf relation
    if index != -1
      @data_relations_visibles.splice index, 1

  updateRelationsLabelsData: ->
    if @node_active
      @updateRelationsLabels @getNodeRelations(@node_active.id)


  # Config Methods
  # ---------------
    
  updateNodesColor: (value) =>
    @parameters.nodesColor = value
    @updateNodesColorValue()

  updateNodesColorColumn: (value) =>
    @updateNodesColorValue()

  updateNodesColorValue: =>
    @setColorScale()
    @data_nodes.forEach (d) =>
      @setNodeFill d
      @setNodeStroke d
      @redraw()

  updateNodesSize: (value) =>
    @parameters.nodesSize = parseInt(value)
    @updateNodesSizeValue()

  updateNodesSizeColumn: (value) =>
    @updateNodesSizeValue()

  updateNodesSizeValue: =>
    # if nodesSize = 1, set nodes size based on its number of relations
    if @parameters.nodesSize == 1
      if @parameters.nodesSizeColumn == 'relations'
        @setNodesRelations()
      @setScaleNodesSize()
      @updateNodes()
      @updateForce true
    else
      # set nodes size & update nodes radius
      @setNodesSize()
      @nodes.attr 'r', (d) -> return d.size
    # # update nodes labels position
    @nodes_labels.attr 'class', @getNodeLabelClass
    @nodes_labels.selectAll('.first-line')
      .attr 'dy', @getNodeLabelYPos
    # update relations arrows position
    @relations.attr 'd', @drawRelationPath

  toogleNodesLabel: (value) =>
    @nodes_labels.classed 'hide', !value

  toogleNodesLabelComplete: (value) =>
    @nodes_labels.attr 'class', @getNodeLabelClass

  toogleNodesImage: (value) =>
    @parameters.showNodesImage = value
    @updateNodes()
  
  # toogleNodesWithoutRelation: (value) =>
  #   if value
  #     @data_nodes.forEach (d) =>
  #       if !@hasNodeRelations(d)
  #         @removeNode d
  #   else
  #     # TODO!!! Check visibility before add a node
  #     @data_nodes.forEach (d) =>
  #       if !@hasNodeRelations(d)
  #         @addNode d
  #   @render()

  updateRelationsCurvature: (value) ->
    @parameters.relationsCurvature = value
    #@onTick()

  updateRelationsLineStyle: (value) ->
    #@relations_cont.attr 'class', 'relations-cont '+@getRelationsLineStyle(value)

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
    @force.alpha(0.15).restart()


  # Auxiliar Methods
  # ----------------

  getNodeRelations: (id) ->
    return @data_relations_visibles.filter (d) => return d.source_id == id || d.target_id == id

  # Checkout!!! We don't use this method
  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) ->
      return d.source_id == node.id || d.target_id == node.id


module.exports = VisualizationCanvasEdit