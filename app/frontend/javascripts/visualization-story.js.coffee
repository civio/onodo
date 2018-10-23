Visualization = require './visualization.js'

class VisualizationStory extends Visualization

  # Override onSync method to set Visualization Canvas offset x & use render(false)
  onSync: =>
    # Setup visualization parameters
    @parameters = $.parseJSON @visualization.get('parameters')
    @setupParameters()
    # Setup VisualizationCanvas
    @visualizationCanvas.setup @nodes, @relations, @parameters
    $('.visualization-graph-component').css 'margin-left', -230 # translate left half the width of Story Info panel
    @visualizationCanvas.render()
    @visualizationNavigation.render()
    @visualizationActions.render @parameters
    # Setup Visualization Events
    @bindVisualizationEvents()
    # Trigger synced event for Stories
    Backbone.trigger 'visualization.synced'

  # Setup a chapter nodes & relations in Visualization Canvas
  showChapter: (nodes, relations) ->
    # Update VisualizationCanvas data based on chapter nodes & relations
    @visualizationCanvas.updateData nodes, relations
    @visualizationCanvas.redraw()

module.exports = VisualizationStory