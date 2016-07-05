class UsersController < ApplicationController

  PAGE_SIZE = 6

  before_action :authenticate_user!, except: [:show, :show_visualizations, :show_stories]
  before_action :set_user, only: [:show, :show_visualizations, :show_stories]

  # GET /users/:id
  def show
    @items = visualizations_for @user, published: true, page: params[:page]
    @show_visualizations = true
    render :show
  end

  # GET /users/:id/visualizations
  alias_method :show_visualizations, :show

  # GET /users/:id/stories
  def show_stories
    @items = stories_for @user, published: true, page: params[:page]
    @show_visualizations = false
    render :show
  end

  # GET /dashboard
  def show_dashboard
    @user = current_user
    @items = visualizations_for @user, published: false, page: params[:page]
    @show_visualizations = true
    render :show
  end

  # GET /dashboard/visualizations
  alias_method :show_dashboard_visualizations, :show_dashboard

  # GET /dashboard/stories
  def show_dashboard_stories
    @user = current_user
    @items = stories_for @user, published: false, page: params[:page]
    @show_visualizations = false
    render :show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def visualizations_for user, published:, page: nil
    visualizations = user.visualizations
    visualizations = visualizations.published if published

    visualizations.page(page).per(PAGE_SIZE)
  end

  def stories_for user, published:, page: nil
    stories = user.stories
    stories = stories.published if published

    stories.page(page).per(PAGE_SIZE)
  end

end