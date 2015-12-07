class HomeController < ApplicationController

  # GET /
  def index
    @visualizations = Visualization.all
    @gallery_items = @visualizations + Story.all
  end
end
