class PagesController < ApplicationController
  # GET /explore
  def explore_visualizations
    @items = Visualization.published
    #@items = @items.order("published_at DESC").includes(:photo).page(params[:page]).per(9)
    @items = @items.page(params[:page]).per(6)
    @show_visualizations = true
    render :explore
  end

  def explore_stories
    @items = Story.published
    @items = @items.page(params[:page]).per(6)
    @show_visualizations = false
    render :explore
  end

  # GET /gallery
  def gallery
    gallery = Gallery.instance
    @items = (gallery.visualizations + gallery.stories).sort_by(&:created_at).reverse
  end
end
