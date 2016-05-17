Chapter = require './../models/chapter.js'

class ChaptersCollection extends Backbone.Collection
  model: Chapter
  url: '/api/chapter'

module.exports = ChaptersCollection