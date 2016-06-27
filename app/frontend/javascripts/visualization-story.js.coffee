Visualization = require './visualization.js'

class VisualizationStory extends Visualization

  # Override onSync method to set Visualization Canvas offset x & use render(false)
  onSync: =>
    # Setup visualization parameters
    @parameters = $.parseJSON @visualization.get('parameters')
    @setupParameters()
    # Setup VisualizationCanvas
    @visualizationCanvas.setup @getVisualizationCanvasData(@nodes.models, @relations.models), @parameters
    @visualizationCanvas.setOffsetX 230 # translate left half the width of Story Info panel 
    @visualizationCanvas.render false
    # Setup Visualization Events
    @setupVisualizationEvents()

  # Setup a chapter nodes & relations in Visualization Canvas
  showChapter: (nodes, relations) ->
    # Update VisualizationCanvas data based on chapter nodes & relations
    @visualizationCanvas.updateData nodes, relations
    @visualizationCanvas.render()

module.exports = VisualizationStory