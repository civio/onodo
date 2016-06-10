Visualization = require './visualization.js'

class VisualizationStory extends Visualization

  # Override onSync method to set Visualization Canvas offset x
  onSync: =>
    super()
    @visualizationCanvas.setOffsetX 230 # translate left half the width of Story Info panel
    
  # Setup a chapter nodes & relations in Visualization Canvas
  showChapter: (nodes, relations) ->
    # We use svg to check if visualizationCanvas has data initialized
    if @visualizationCanvas.svg
      # Update VisualizationCanvas data
      @visualizationCanvas.updateData nodes, relations
    else
      # Filter collection nodes & relations based on chapter nodes & relations
      chapterNodes     = @nodes.models.filter     (d) => return nodes.indexOf(d.id) != -1
      chapterRelations = @relations.models.filter (d) => return relations.indexOf(d.id) != -1  
      # Update VisualizationCanvas data
      @visualizationCanvas.setup @getVisualizationCanvasData(chapterNodes, chapterRelations), @visualizationConfiguration.parameters
      @visualizationCanvas.setOffsetX 230 # translate left half the width of Story Info panel  
    # render VisualizationCanvas
    @visualizationCanvas.render()

module.exports = VisualizationStory