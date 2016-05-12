class PagesController < ApplicationController

  # GET /explore
  def explore_visualizations
    @items = Visualization.published
    #@items = @items.order("published_at DESC").includes(:photo).page(params[:page]).per(9)
    @items = @items.page(params[:page]).per(6)
    @visualizations = true
    render :explore
  end

  def explore_stories
    @items = Story.published
    @items = @items.page(params[:page]).per(6)
    render :explore
  end

  # GET /gallery
  def gallery
    visualizations = Visualization.published
    stories = Story.published
    @items = (visualizations + stories).sort_by(&:created_at).reverse
  end
  
end
