class PagesController < ApplicationController

  # GET /explore
  def explore
    @items = Visualization.all
    #@items = @items.order("published_at DESC").includes(:photo).page(params[:page]).per(9)
    #@stories = Story.all
    @items = @items.page(params[:page]).per(6)
  end

  # GET /gallery
  def gallery
    visualizations = Visualization.all
    stories = Story.all
    @items = (visualizations + stories).sort_by(&:created_at).reverse
  end
  
end
