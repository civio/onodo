class HomeController < ApplicationController

  # GET /
  def index
    gallery = Gallery.instance
    @gallery_items = gallery.visualizations + gallery.stories
  end
end
