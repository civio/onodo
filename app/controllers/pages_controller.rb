class PagesController < ApplicationController

  # GET /explore
  def explore
    @visualizations = Visualization.all
  end

  # GET /gallery
  def gallery
    @visualizations = Visualization.all
  end
end
