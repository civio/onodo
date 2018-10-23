class PagesController < ApplicationController
  # GET /explore
  def explore_visualizations
    @items = Visualization.published.order(created_at: :desc)
    @items = @items.search(params[:search]) if params[:search].present?
    #@items = @items.order("published_at DESC").includes(:photo).page(params[:page]).per(9)
    @items = @items.page(params[:page]).per(6)
    @show_visualizations = true
    render :explore
  end

  def explore_stories
    @items = Story.published.order(created_at: :desc)
    @items = @items.search(params[:search]) if params[:search].present?
    @items = @items.page(params[:page]).per(6)
    @show_visualizations = false
    render :explore
  end

  # GET /gallery
  def gallery
    gallery = Gallery.instance
    @items = (gallery.visualizations + gallery.stories).sort_by(&:created_at).reverse
  end

  # GET /demo
  def demo
    id = Visualization.next_id
    name = "Demo onodo-viz-#{id}"
    dataset = Dataset.new

    sign_in(demo_user) unless current_user

    @demo = true
    @visualization = Visualization.create(id: id, name: name, dataset: dataset, author: demo_user)

    render 'visualizations/edit'
  end

  # GET /terms-of-service/modal
  def terms_of_service_modal
    render :layout => false
  end

  # GET /terms-of-service
  def terms_of_service
  end

  # GET /privacy-policy
  def privacy_policy
  end

  # GET /documentation
  def documentation
  end

  # GET /locale/:locale
  def change_locale
    locale = params[:locale].downcase
    locale = I18n.default_locale unless I18n.locale_available? locale
    session[:locale] = locale
    redirect_to request.referer || root_path
  end
end
