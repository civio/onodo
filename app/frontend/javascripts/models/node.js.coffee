class Node extends Backbone.Model
  paramRoot: 'node'
  defaults:
    name:         null
    description:  null
    visible:      true
    node_type:    null
    image:        null

module.exports = Node