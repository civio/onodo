Node = require './../models/node.js'

class NodesCollection extends Backbone.Collection
  model: Node
  url: '/api/nodes'

module.exports = NodesCollection