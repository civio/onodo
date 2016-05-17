class Chapter extends Backbone.Model
  paramRoot: 'chapter'
  defaults:
    name:         null
    description:  null
    number:       null
    nodes:        null
    relations:    null

module.exports = Chapter