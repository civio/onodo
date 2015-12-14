class PagesController < ApplicationController

  # GET /explore
  def explore_visualizations
    @items = Visualization.all
    #@items = @items.order("published_at DESC").includes(:photo).page(params[:page]).per(9)
    @items = @items.page(params[:page]).per(2)
    @visualizations = true
    render :explore
  end

  def explore_stories
    @items = Story.all
    @items = @items.page(params[:page]).per(2)
    render :explore
  end

  # GET /gallery
  def gallery
    visualizations = Visualization.all
    stories = Story.all
    @items = (visualizations + stories).sort_by(&:created_at).reverse
  end
  
end
