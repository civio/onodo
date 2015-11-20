class PagesController < ApplicationController

  # GET /explore
  def explore
    @visualizations = Visualization.all
    @stories = Story.all
  end

  # GET /gallery
  def gallery
    visualizations = Visualization.all
    stories = Story.all
    @items = (visualizations + stories).sort_by(&:created_at).reverse
  end
  
end
