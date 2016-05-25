class HomeController < ApplicationController

  # GET /
  def index
    @gallery_items = Visualization.published + Story.published
  end
end
