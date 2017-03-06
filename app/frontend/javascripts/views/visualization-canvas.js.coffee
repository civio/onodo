d3 = require '../dist/d3'

class VisualizationCanvas extends Backbone.View

  el: '.visualization-graph-component' 

  COLOR_SOLID:
    'solid-1': '#ef9387'
    'solid-2': '#fccf80'
    'solid-3': '#fee378'
    'solid-4': '#d9d070'
    'solid-5': '#82a389'
    'solid-6': '#87948f'
    'solid-7': '#89b5df'
    'solid-8': '#aebedf'
    'solid-9': '#c6a1bc'
    'solid-10': '#f1b6ae'
    'solid-11': '#a8a6a0'
    'solid-12': '#e0deda'
  COLOR_QUALITATIVE:  ['#88b5df', '#fbcf80', '#82a288','#ffebad', '#c5a0bb', '#dfdeda', '#a8a69f', '#ee9286', '#d9d06f', '#f0b6ad']
  COLOR_QUANTITATIVE: ['#fff0c2', '#ffe795', '#fedf69', '#fed63c', '#b5ba7c', '#6d9ebb', '#2482fb', '#2b64c5', '#31458f', '#382759']

  svg:                    null
  defs:                   null
  container:              null
  data:                   null
  data_nodes:             []
  data_nodes_map:         d3.map()
  data_relations:         []
  data_relations_visibles:[]
  nodes_cont:             null
  nodes_labels_cont:      null
  relations_cont:         null
  relations_labels_cont:  null
  nodes:                  null
  nodes_labels:           null
  relations:              null
  relations_labels:       null
  force:                  null
  forceDrag:              null
  forceLink:              null
  forceManyBody:          null
  linkedByIndex:          {}
  parameters:             null
  color_scale:            null
  node_active:            null
  scale_nodes_size:       null
  scale_labels_size:      null
  degrees_const:          180 / Math.PI
  # Viewport object to store drag/zoom values
  viewport:
    width: 0
    height: 0
    center:
      x: 0
      y: 0
    origin:
      x: 0
      y: 0
    x: 0
    y: 0
    dx: 0
    dy: 0
    offsetx: 0
    offsety: 0
    offsetnode:
      x: 0
      y: 0
    drag:
      x: 0
      y: 0
    scale: 1

  setup: (_data, _parameters) ->

    @parameters = _parameters

    # Setup Data
    @initializeData _data

    # Setup Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.center.x  = @viewport.width*0.5
    @viewport.center.y  = @viewport.height*0.5

    # Setup force
    @forceLink = d3.forceLink()
      .id       (d) -> return d.id
      .distance ()  => return @parameters.linkDistance

    @forceManyBody = d3.forceManyBody()
      # (https://github.com/d3/d3-force#manyBody_strength)
      .strength () => return @parameters.linkStrength
      # set maximum distance between nodes over which this force is considered
      # (https://github.com/d3/d3-force#manyBody_distanceMax)
      .distanceMax 500
      #.theta        @parameters.theta

    @force = d3.forceSimulation()
      .force 'link',    @forceLink
      .force 'charge',  @forceManyBody
      .force 'center',  d3.forceCenter(@viewport.center.x, @viewport.center.y)
      .on    'tick',    @onTick

    # Reduce number of force ticks until the system freeze
    # (https://github.com/d3/d3-force#simulation_alphaDecay)
    @force.alphaDecay 0.03

    # @force = d3.layout.force()
    #   .linkDistance @parameters.linkDistance
    #   .linkStrength @parameters.linkStrength
    #   .friction     @parameters.friction
    #   .charge       @parameters.charge
    #   .theta        @parameters.theta
    #   .gravity      @parameters.gravity
    #   .size         [@viewport.width, @viewport.height]
    #   .on           'tick', @onTick

    @forceDrag = d3.drag()
      .on('start',  @onNodeDragStart)
      .on('drag',   @onNodeDragged)
      .on('end',    @onNodeDragEnd)

    svgDrag = d3.drag()
      .on('start',  @onCanvasDragStart)
      .on('drag',   @onCanvasDragged)
      .on('end',    @onCanvasDragEnd)

    # Setup SVG
    @svg = d3.select('svg')
      .attr 'width',  @viewport.width
      .attr 'height', @viewport.height
      .call svgDrag

    # Define Arrow Markers
    @defs = @svg.append('defs')
    # Setup arrow 
    @defs.append('marker')
        .attr 'id', 'arrow'
        .attr 'class', 'arrow-marker'
        .attr 'viewBox', '-8 -10 8 20'
        .attr 'refX', 2
        .attr 'refY', 0
        .attr 'markerWidth', 10
        .attr 'markerHeight', 10
        .attr 'orient', 'auto'
      .append 'path'
        .attr 'd', 'M -10 -8 L 0 0 L -10 8'

    # if nodesSize = 1, set nodes size
    if @parameters.nodesSize == 1
      # set relations attribute in nodes
      if @parameters.nodesSizeColumn == 'relations'
        @setNodesRelations()
      @setScaleNodesSize()

    # Setup containers
    @container             = @svg.append('g')
    @relations_cont        = @container.append('g').attr('class', 'relations-cont '+@getRelationsLineStyle(@parameters.relationsLineStyle))
    @relations_labels_cont = @container.append('g').attr('class', 'relations-labels-cont')
    @nodes_cont            = @container.append('g').attr('class', 'nodes-cont')
    @nodes_labels_cont     = @container.append('g').attr('class', 'nodes-labels-cont')

    # Translate svg
    @rescale()

    # Remove loading class
    @$el.removeClass 'loading'  


  initializeData: (data) ->

    # console.log 'initializeData'

    @data_nodes              = []
    @data_relations          = []
    @data_relations_visibles = []

    # Setup Nodes
    data.nodes.forEach (d) =>
      if d.visible
        @addNodeData d
      # force empties node_types to null to avoid 2 non-defined types 
      if d.node_type == ''
        d.node_type = null

    # Setup color scale
    @setColorScale()

    # Setup Relations: change relations source & target N based id to 0 based ids & setup linkedByIndex object
    data.relations.forEach (d) =>
      # Set source & target as nodes objetcs instead of index number
      d.source = @getNodeById d.source_id
      d.target = @getNodeById d.target_id
      # Add all relations to data_relations array
      @data_relations.push d
      # Add relation to data_relations_visibles array if both nodes exist and are visibles
      if d.source and d.target and d.source.visible and d.target.visible
        @data_relations_visibles.push d
        @addRelationToLinkedByIndex d.source_id, d.target_id

    # Add linkindex to relations
    #@setLinkIndex()

    #console.log 'current nodes', @data_nodes
    #console.log 'current relations', @data_relations_visibles

  clear: ->
    # Add loading class
    @$el.addClass 'loading'
    # Clear all containers
    @container.remove()
    @relations_cont.remove()
    @relations_labels_cont.remove()
    @nodes_cont.remove()
    @nodes_labels_cont.remove()

  render: ( restarForce ) ->
    @updateImages()
    @updateRelations()
    @updateNodes()
    @updateNodesLabels()
    @updateForce restarForce

  updateImages: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    patterns = @defs.selectAll('filter').data(@data_nodes.filter (d) -> return d.image != null)

    # EXIT old elements not present in new data
    patterns.exit().remove()

    # UPDATE old elements present in new data
    patterns.attr('id', (d) -> return 'node-pattern-'+d.id)
      .selectAll('image')
        .attr('xlink:href', (d) -> return d.image.small.url)
    
    # ENTER new elements present in new data.
    patterns.enter().append('pattern')
      .attr('id', (d) -> return 'node-pattern-'+d.id)
      .attr('x', '0')
      .attr('y', '0')
      .attr('width', '100%')
      .attr('height', '100%')
      .attr('viewBox', '0 0 30 30')
      .append('image')
        .attr('x', '0')
        .attr('y', '0')
        .attr('width', '30')
        .attr('height', '30')
        .attr('xlink:href', (d) -> return d.image.small.url)


  updateNodes: ->
    # Set nodes size
    @setNodesSize()

    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes = @nodes_cont.selectAll('.node').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes.exit().remove()

    # UPDATE old elements present in new data
    @nodes
      .attr 'id',       (d) -> return 'node-'+d.id
      .attr 'class',    (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       (d) -> return d.size
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeStroke

    # ENTER new elements present in new data.
    @nodes.enter().append('circle')
      .attr  'id',      (d) -> return 'node-'+d.id
      .attr  'class',   (d) -> return if d.disabled then 'node disabled' else 'node'
      # update node size
      .attr  'r',       (d) -> return d.size
      # set position at viewport center
      .attr  'cx',      @viewport.center.x
      .attr  'cy',      @viewport.center.y
      # set nodes color based on parameters.nodesColor value or image as pattern if defined
      .style 'fill',    @getNodeFill
      .style 'stroke',  @getNodeStroke
      .on   'mouseover',  @onNodeOver
      .on   'mouseout',   @onNodeOut
      .on   'click',      @onNodeClick
      .on   'dblclick',   @onNodeDoubleClick
      .call @forceDrag

    @nodes = @nodes_cont.selectAll('.node')

  updateRelations: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @relations = @relations_cont.selectAll('.relation').data(@data_relations_visibles)

    # EXIT old elements not present in new data
    @relations.exit().remove()

    # UPDATE old elements present in new data
    @relations
      .attr 'id',           (d) -> return 'relation-'+d.id
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      .attr 'marker-end',   (d) -> return if d.direction then 'url(#arrow)' else ''

    # ENTER new elements present in new data.
    @relations.enter().append('path')
      .attr 'id',           (d) -> return 'relation-'+d.id
      .attr 'class',        (d) -> return if d.disabled then 'relation disabled' else 'relation'
      .attr 'marker-end',   (d) -> return if d.direction then 'url(#arrow)' else ''

    @relations = @relations_cont.selectAll('.relation')

  updateNodesLabels: ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @nodes_labels = @nodes_labels_cont.selectAll('.node-label').data(@data_nodes)

    # EXIT old elements not present in new data
    @nodes_labels.exit().remove()

    # UPDATE old elements present in new data
    @nodes_labels
      .attr 'id',    (d,i) -> return 'node-label-'+d.id
      .attr 'class', 'node-label'
      .attr 'dy',    @getNodeLabelYPos
      .text (d) -> return d.name
      .call @formatNodesLabels

    # ENTER new elements present in new data
    @nodes_labels.enter().append('text')
      .attr 'id',    (d,i) -> return 'node-label-'+d.id
      .attr 'class', 'node-label'
      .attr 'dx',    0
      .attr 'dy',    @getNodeLabelYPos
      .text (d) -> return d.name
      .call @formatNodesLabels

    @nodes_labels = @nodes_labels_cont.selectAll('.node-label')

    # we need to update labels class after call to formatNodesLabels
    # in order to use same font-size for getComputedTextLength
    @nodes_labels.attr 'class', @getNodeLabelClass

  updateRelationsLabels: (data) ->
    # Use General Update Pattern 4.0 (https://bl.ocks.org/mbostock/a8a5baa4c4a470cda598)

    # JOIN new data with old elements
    @relations_labels = @relations_labels_cont.selectAll('.relation-label').data(data)

    # EXIT old elements not present in new data
    @relations_labels.exit().remove()

    # UPDATE old elements present in new data
    @relations_labels.text((d) -> return d.relation_type)
    #@relations_labels.selectAll('textPath').text((d) -> return d.relation_type)

    # ENTER new elements present in new data.
    @relations_labels.enter()
      .append('text')
        .attr  'id', (d) -> return 'relation-label-'+d.id
        .attr  'class', 'relation-label'
        #.attr  'x', (d) -> return (d.source.x+d.target.x)*0.5
        #.attr  'y', (d) -> return (d.source.y+d.target.y)*0.5
        .attr  'dy', '-0.3em'
        .attr  'transform', @getRelationLabelTransform
        .style 'text-anchor', 'middle'
        .text  (d) -> return d.relation_type

      # .append('text')
      #   .attr('id', (d) -> return 'relation-label-'+d.id)
      #   .attr('class', 'relation-label')
      #   .attr('x', 0)
      #   .attr('dy', -4)
      # .append('textPath')
      #   .attr('xlink:href',(d) -> return '#relation-'+d.id) # link textPath to label relation
      #   .style('text-anchor', 'middle')
      #   .attr('startOffset', '50%') 
      #   .text((d) -> return d.relation_type)

    @relations_labels = @relations_labels_cont.selectAll('.relation-label')


  updateForce: (restarForce) ->
    # update force nodes & links
    @force.nodes(@data_nodes)
    @force.force('link').links(@data_relations_visibles)
    # restart force
    if restarForce
      @force.alpha(0.3).restart()

  updateData: (nodes, relations) ->
    # console.log 'canvas current Data', @data_nodes, @data_relations
    # Setup disable values in nodes
    @data_nodes.forEach (node) ->
      node.disabled = nodes.indexOf(node.id) == -1
    # Setup disable values in relations
    @data_relations_visibles.forEach (relation) ->
      relation.disabled = relations.indexOf(relation.id) == -1    

  addNodeData: (node) ->
    # check if node is present in @data_nodes
    #console.log 'addNodeData', node.id, node
    if node
      @data_nodes_map.set node.id, node
      @data_nodes.push node

  removeNodeData: (node) ->
    @data_nodes_map.remove node.id
    # We can't use Array.splice because this function could be called inside a loop over nodes & causes drop
    @data_nodes = @data_nodes.filter (d) =>
      return d.id != node.id
  
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

  removeVisibleRelationData: (relation) =>
    #console.log 'remove relation from data_relations_visibles', @data_relations_visibles
    # remove relation from data_relations_visibles
    index = @data_relations_visibles.indexOf relation
    if index != -1
      @data_relations_visibles.splice index, 1

  addRelationToLinkedByIndex: (source, target) ->
    # count number of relations between 2 nodes
    @linkedByIndex[source+','+target] = ++@linkedByIndex[source+','+target] || 1

  updateRelationsLabelsData: ->
    if @node_active
      @updateRelationsLabels @getNodeRelations(@node_active.id)

  # Add a linkindex property to relations
  # Based on https://github.com/zhanghuancs/D3.js-Node-MultiLinks-Node
  setLinkIndex: ->
    # Sort relations
    @data_relations_visibles.sort (a,b) ->
      if a.source_id > b.source_id
        return 1
      else if a.source_id < b.source_id
        return -1
      else 
        if a.target_id > b.target_id
          return 1
        else if a.target_id < b.target_id
          return -1
        else
          return 0
    # set linkindex attr
    @data_relations_visibles.forEach (relation, i) =>
      if i != 0 && @data_relations_visibles[i].source_id == @data_relations_visibles[i-1].source_id && @data_relations_visibles[i].target_id == @data_relations_visibles[i-1].target_id
        @data_relations_visibles[i].linkindex = @data_relations_visibles[i-1].linkindex + 1
      else
        @data_relations_visibles[i].linkindex = 1

  addNode: (node) ->
    #console.log 'addNode', node
    @addNodeData node
    @render true
    # !!! We need to check if this node has some relation

  removeNode: (node) ->
    #console.log 'removeNode', node
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

  addRelation: (relation) ->
    #console.log 'addRelation', relation
    @addRelationData relation
    # update nodes relations size if needed to take into acount the added relation
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @render true

  removeRelation: (relation) ->
    #console.log 'removeRelation', relation
    @removeRelationData relation
    @updateRelationsLabelsData()
    # update nodes relations size if needed to take into acount the removed relation
    if @parameters.nodesSize == 1 and @parameters.nodesSizeColumn == 'relations'
      @setNodesRelations()
    @render true

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

  focusNode: (node) ->
    if @node_active
      # clear previous focused nodes
      @nodes_cont.selectAll('#node-'+@node_active.id)
        .style 'stroke',  @getNodeStroke
      @node_active = null
      # force node over
      @onNodeOver node
    # set node active
    @node_active = node
    @nodes_cont.selectAll('.node.active')
      .classed 'active', false
    @nodes_cont.selectAll('#node-'+node.id)
      .classed 'active', true
      .style   'stroke', @getNodeStroke
    @updateRelationsLabelsData()
    # center viewport in node
    @centerNode node

  unfocusNode: ->
    if @node_active
      @nodes_cont.selectAll('#node-'+@node_active.id)
        .style 'stroke',  @getNodeStroke
      @nodes_cont.selectAll('.node.active')
        .classed 'active', false
      @node_active = null
      @onNodeOut()
      # center viewport
      @centerNode null

  centerNode: (node) ->
    if node
      @viewport.offsetnode.x = (@viewport.scale * (node.get('x') - @viewport.center.x)) + @viewport.x + 175 # 175 = $('.visualization-graph-info').height() / 2
      @viewport.offsetnode.y = (@viewport.scale * (node.get('y') - @viewport.center.y)) + @viewport.y
    else
      @viewport.offsetnode.x = @viewport.offsetnode.y = 0
    @rescaleTransition()

  sortNodes: (a, b) ->
    if a.size > b.size
      return 1
    else if a.size > b.size
      return -1
    return 0


  # Resize Methods
  # ---------------

  resize: ->
    #console.log 'VisualizationGraphCanvas resize'
    # Update Viewport attributes
    @viewport.width     = @$el.width()
    @viewport.height    = @$el.height()
    @viewport.origin.x  = (@viewport.width*0.5) - @viewport.center.x
    @viewport.origin.y  = (@viewport.height*0.5) - @viewport.center.y

    # Update canvas
    @svg.attr   'width', @viewport.width
    @svg.attr   'height', @viewport.height
    @rescale()
    # Update force size
    #@force.size [@viewport.width, @viewport.height] 

  rescale: ->
    @container.attr       'transform', @getContainerTransform()
    translateStr = 'translate(' + (-@viewport.center.x) + ',' + (-@viewport.center.y) + ')'
    @relations_cont.attr        'transform', translateStr
    @relations_labels_cont.attr 'transform', translateStr
    @nodes_cont.attr            'transform', translateStr
    @nodes_labels_cont.attr     'transform', translateStr

  rescaleTransition: ->
    @container.transition()
      .duration 500
      .ease     d3.easeQuadOut
      .attr     'transform', @getContainerTransform()

  setOffsetX: (offset) ->
    @viewport.offsetx = if offset < 0 then 0 else offset
    @rescaleTransition()

  setOffsetY: (offset) ->
    @viewport.offsety = if offset < 0 then 0 else offset
    if @container
      @container.attr 'transform', @getContainerTransform()

   getContainerTransform: ->
    return 'translate(' + (@viewport.center.x+@viewport.origin.x+@viewport.x-@viewport.offsetx-@viewport.offsetnode.x) + ',' + (@viewport.center.y+@viewport.origin.y+@viewport.y-@viewport.offsety-@viewport.offsetnode.y) + ')scale(' + @viewport.scale + ')'


  # Config Methods
  # ---------------

  setColorScale: ->
    if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      color_scale_domain = @data_nodes.map (d) => return d[@parameters.nodesColorColumn]
      if @parameters.nodesColor == 'qualitative' 
        @color_scale = d3.scaleOrdinal().range @COLOR_QUALITATIVE
        @color_scale.domain _.uniq(color_scale_domain)
        #console.log 'color_scale_domain', _.uniq(color_scale_domain)
      else
        @color_scale = d3.scaleQuantize().range @COLOR_QUANTITATIVE
        # get max scale value avoiding undefined result
        color_scale_max = d3.max(color_scale_domain)
        unless color_scale_max
          color_scale_max = 0
        @color_scale.domain [0, color_scale_max]
        #console.log 'color_scale_domain', d3.max(color_scale_domain)
      # @color_scale = d3.scaleViridis()
      #   .domain([d3.max(color_scale_domain), 0])
    
  updateNodesColor: (value) =>
    @parameters.nodesColor = value
    @updateNodesColorValue()

  updateNodesColorColumn: (value) =>
    @updateNodesColorValue()

  updateNodesColorValue: =>
    @setColorScale()
    @nodes
      .style 'fill',   @getNodeFill
      .style 'stroke', @getNodeStroke

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
    @relations_cont.attr 'class', 'relations-cont '+@getRelationsLineStyle(value)

  getRelationsLineStyle: (value) ->
    lineStyle = switch
      when value == 0 then 'line-solid'
      when value == 1 then 'line-dashed'
      else 'line-dotted' 
    return lineStyle

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


  # Navigation Methods
  # ---------------

  zoomIn: ->
    @zoom @viewport.scale*1.2
    
  zoomOut: ->
    @zoom @viewport.scale/1.2
  
  zoom: (value) ->
    @viewport.scale = value
    @container
      .transition()
        .duration 500
        .attr     'transform', @getContainerTransform()


  # Events Methods
  # ---------------

  # Canvas Drag Events
  onCanvasDragStart: =>
    @svg.style('cursor','move')

  onCanvasDragged: =>
    @viewport.x  += d3.event.dx
    @viewport.y  += d3.event.dy
    @viewport.dx += d3.event.dx
    @viewport.dy += d3.event.dy
    @rescale()
    d3.event.sourceEvent.stopPropagation()  # silence other listeners

  onCanvasDragEnd: =>
    @svg.style('cursor','default')
    # Skip if viewport has no translation
    if @viewport.dx == 0 and @viewport.dy == 0
      Backbone.trigger 'visualization.node.hideInfo'
      return
    # TODO! Add viewportMove action to history
    @viewport.dx = @viewport.dy = 0;
   
  # Nodes drag events
  onNodeDragStart: (d) =>
    if !d3.event.active
      @force.alphaTarget(0.1).restart()
  
  onNodeDragged: (d) =>
    d.fx = d3.event.x
    d.fy = d3.event.y

  onNodeDragEnd: (d) =>
    if !d3.event.active
      @force.alphaTarget(0)

  onNodeOver: (d) =>
    # skip if any node is active
    if @node_active
      return
    # add relations labels  
    @updateRelationsLabels @getNodeRelations(d.id)
    # highlight related nodes labels
    @nodes_labels.classed 'weaken', true
    @nodes_labels.classed 'highlighted', (o) => return @areNodesRelated(d, o)
    # highlight node relations
    @relations.classed 'weaken', true
    @relations.classed 'highlighted', (o) => return o.source_id == d.id || o.target_id == d.id

  onNodeOut: (d) =>
    # skip if any node is active
    if @node_active
      return
    # clear relations labels
    @updateRelationsLabels {}
    # clear nodes & relations classes
    @nodes_labels.classed 'weaken', false
    @nodes_labels.classed 'highlighted', false
    @relations.classed 'weaken', false
    @relations.classed 'highlighted', false

  onNodeClick: (d) =>
    # Avoid trigger click on dragEnd
    if d3.event.defaultPrevented 
      return
    Backbone.trigger 'visualization.node.showInfo', {node: d.id}

  onNodeDoubleClick: (d) =>
    # unfix the node position when the node is double clicked
    @force.unfix d

  # Tick Function
  onTick: =>
    #console.log 'on tick'
    # Set relations path & arrow markers
    @relations
      .attr 'd', @drawRelationPath
      #.attr('marker-end', @getRelationMarkerEnd)
      #.attr('marker-start', @getRelationMarkerStart)
    # Set nodes & labels position
    @nodes
      .attr 'cx', (d) -> return d.x
      .attr 'cy', (d) -> return d.y
    # Set nodes labels position
    @nodes_labels
      .attr 'transform', (d) -> return 'translate(' + d.x + ',' + d.y + ')'
    # Set relation labels position
    if @relations_labels
      @relations_labels
        .attr 'transform', @getRelationLabelTransform
  
  drawRelationPath: (d) =>
    # vector auxiliar methods from https://stackoverflow.com/questions/13165913/draw-an-arrow-between-two-circles
    length  = ({x,y}) -> Math.sqrt(x*x + y*y)
    sum     = ({x:x1,y:y1}, {x:x2,y:y2}) -> {x:x1+x2, y:y1+y2}
    diff    = ({x:x1,y:y1}, {x:x2,y:y2}) -> {x:x1-x2, y:y1-y2}
    prod    = ({x,y}, scalar) -> {x:x*scalar, y:y*scalar}
    div     = ({x,y}, scalar) -> {x:x/scalar, y:y/scalar}
    unit    = (vector) -> div(vector, length(vector))
    scale   = (vector, scalar) -> prod(unit(vector), scalar)
    free    = ([coord1, coord2]) -> diff(coord2, coord1)

    if d.direction
      v2 = scale free([d.source, d.target]), d.target.size
      p2 = diff d.target, v2
      return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + p2.x + ' ' + p2.y
    else
      return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y


  # Auxiliar Methods
  # ----------------

  getNodeById: (id) ->
    return @data_nodes_map.get id

  getNodeRelations: (id) ->
    return @data_relations_visibles.filter (d) => return d.source_id == id || d.target_id == id

  hasNodeRelations: (node) ->
    return @data_relations_visibles.some (d) ->
      return d.source_id == node.id || d.target_id == node.id

  areNodesRelated: (a, b) ->
    return @linkedByIndex[a.id + ',' + b.id] || @linkedByIndex[b.id + ',' + a.id] || a.id == b.id

  getNodeLabelClass: (d) =>
    #console.log 'getNodeLabelClass', @parameters.nodesSize 
    str = 'node-label'
    if !@parameters.showNodesLabel
      str += ' hide'
    if @parameters.showNodesLabelComplete 
      str += ' complete'
    if d.disabled
      str += ' disabled'
    if @parameters.nodesSize == 1
      str += ' size-'+@scale_labels_size(d[@parameters.nodesSizeColumn])
    return str

  getNodeLabelYPos: (d) =>
    return parseInt(@nodes_cont.select('#node-'+d.id).attr('r'))+13

  getNodeStroke: (d) =>
    if @node_active and d.id == @node_active.id
      if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
        color = @color_scale d[@parameters.nodesColorColumn]
      else
        color = @COLOR_SOLID[@parameters.nodesColor]
    else
      color = 'transparent'
    return color

  getNodeFill: (d) =>
    if d.disabled
      fill = '#d3d7db'
    else if @parameters.showNodesImage and d.image != null
      fill = 'url(#node-pattern-'+d.id+')'
    else if @parameters.nodesColor == 'qualitative' or @parameters.nodesColor == 'quantitative'
      fill = @color_scale d[@parameters.nodesColorColumn] 
    else
      fill = @COLOR_SOLID[@parameters.nodesColor]
    return fill

  setNodesSize: =>
    # set size in nodes data
    @data_nodes.forEach (d) =>
      # fixed nodes size 
      if @parameters.nodesSize != 1
        d.size = @parameters.nodesSize
      # nodes size based on number of relations or custom_fields
      else
        val = if d[@parameters.nodesSizeColumn] then d[@parameters.nodesSizeColumn] else 0
        d.size = @scale_nodes_size val
    # Reorder nodes data if size is dynamic (in order to add bigger nodes after small ones)
    if @parameters.nodesSize == 1
      @data_nodes = @data_nodes.sort @sortNodes

  getRelationLabelTransform: (d) =>
    x = (d.source.x+d.target.x)*0.5
    y = (d.source.y+d.target.y)*0.5
    angle = @getAngleBetweenPoints(d.source, d.target)
    if angle > 90 or angle < -90
      angle += 180
    return "translate(#{ x },#{ y }) rotate(#{ angle })"

  setNodesRelations: =>
    # initialize relations attribute for each node with zero value
    @data_nodes.forEach (d) =>
      d.relations = 0
    # increment relation attributes for each relation
    @data_relations_visibles.forEach (d) =>
      d.source.relations += 1
      d.target.relations += 1
    
  setScaleNodesSize: =>
    # set node size scale
    if @data_nodes.length > 0
      maxValue = d3.max @data_nodes, (d) => return d[@parameters.nodesSizeColumn]
    else 
      maxValue = 0
    # avoid undefined values
    unless maxValue
      maxValue = 0
    # set nodes size scale
    @scale_nodes_size = d3.scaleLinear()
      .domain [0, maxValue]
      .range [5, 20]
    # set labels size scale
    @scale_labels_size = d3.scaleQuantize()
      .domain [0, maxValue]
      .range [1, 2, 3, 4]

  getAngleBetweenPoints: (p1, p2) ->
    return Math.atan2(p2.y - p1.y, p2.x - p1.x) * @degrees_const
    #return Math.acos( (p1.x * p2.x + p1.y * p2.y) / ( Math.sqrt(p1.x*p1.x + p1.y*p1.y) * Math.sqrt(p2.x*p2.x + p2.y*p2.y) ) ) * 180 / Math.PI

  formatNodesLabels: (nodes) =>
    nodes.each () ->
      node = d3.select(this)
      name = node.text()
      if name != null and name != ''
        words = name.trim().split(/\s+/).reverse()
        line = []
        i = 0
        dy = parseFloat node.attr('dy')
        tspan = node.text(null).append('tspan')
          .attr('class', 'first-line')
          .attr('x', 0)
          .attr('dx', 5)
          .attr('dy', dy)
        while word = words.pop()
          line.push word
          tspan.text line.join(' ')
          if tspan.node().getComputedTextLength() > 130
            line.pop()
            tspan.text line.join(' ')
            line = [word]
            # if firs tspan, we add ellipsis
            if i == 0
              node.append('tspan')
                .attr('class', 'ellipsis')
                .attr('dx', 2)
                .text('...')
            tspan = node.append('tspan')
              .attr('x', 0)
              .attr('dy', 13)
              .text(word)
            i++
        # reset dx if label is not multiline
        if i == 0
          tspan.attr('dx', 0)


  String.prototype.capitalize = () ->
    return this.charAt(0).toUpperCase() + this.slice(1)

module.exports = VisualizationCanvas