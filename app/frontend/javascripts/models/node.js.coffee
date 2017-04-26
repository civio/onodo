class Node extends Backbone.Model
  paramRoot: 'node'
  defaults:
    name:         null
    description:  null
    visible:      true
    node_type:    null
    image:        null
    posx:         null
    posy:         null

module.exports = Node