Story = require './story.js'

class StoryEdit extends Story

  # Override constructor to set StoryInfo edit parameter to true 
  constructor: (_story_id, _visualization_id) ->
    super _story_id, _visualization_id
    @storyInfo .edit = true

  # Override onChaptersSync to avoid initialize first chapter
  onChaptersSync: (e) =>
    return

module.exports = StoryEdit