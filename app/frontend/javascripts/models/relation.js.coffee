class Relation extends Backbone.Model
  paramRoot: 'relation'
  defaults:
    source_id:        null
    target_id:        null
    relation_type:    null

module.exports = Relation