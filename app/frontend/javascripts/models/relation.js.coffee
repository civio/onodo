class Relation extends Backbone.Model
  paramRoot: 'relation'
  defaults:
    source_id:        null
    source_name:      null
    target_id:        null
    target_name:      null
    relation_type:    null

module.exports = Relation