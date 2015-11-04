Relation = require './../models/relation.js'

class RelationsCollection extends Backbone.Collection
  model: Relation
  url: '/api/relations'

module.exports = RelationsCollection