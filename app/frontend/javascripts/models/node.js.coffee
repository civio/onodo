class Node extends Backbone.Model
  paramRoot: 'node'
  defaults:
    name:         null
    description:  null
    visible:      false
    node_type:    null

module.exports = Node