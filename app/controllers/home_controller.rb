class HomeController < ApplicationController

  # GET /
  def index
    @visualizations = Visualization.all
  end
end
