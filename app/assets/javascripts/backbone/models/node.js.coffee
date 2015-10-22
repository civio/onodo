class Onodo.Models.Node extends Backbone.Model
  paramRoot: 'node'

  defaults:
    name: null
    description: null
    visible: false
    node_type: null

class Onodo.Collections.NodesCollection extends Backbone.Collection
  model: Onodo.Models.Node
  url: '/api/nodes'
