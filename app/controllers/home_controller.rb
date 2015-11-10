class HomeController < ApplicationController

  def index
    @visualizations = Visualization.all
  end
end
