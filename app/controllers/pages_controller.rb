class PagesController < ApplicationController

  def explore
    @visualizations = Visualization.all
  end

  def gallery
    @visualizations = Visualization.all
  end
end
