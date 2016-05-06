class UsersController < ApplicationController

  PAGE_SIZE = 2

  # GET /users/:id
  def show
    @user = user_for params[:id]
    @items = visualizations_for @user, params[:page]
    @visualizations = true
    render :show
  end

  # GET /users/:id/visualizations
  alias_method :show_visualizations, :show

  # GET /users/:id/stories
  def show_stories
    @user = user_for params[:id]
    @items = stories_for @user, params[:page]
    render :show
  end

  # GET /dashboard
  def show_dashboard
    return unless current_user
    @user = current_user
    @items = visualizations_for @user, params[:page]
    @visualizations = true
    render :show
  end

  # GET /dashboard/visualizations
  alias_method :show_dashboard_visualizations, :show_dashboard

  # GET /dashboard/stories
  def show_dashboard_stories
    return unless current_user
    @user = current_user
    @items = stories_for @user, params[:page]
    render :show
  end

  private

  def user_for user_id
    User.find(user_id)
  end

  def visualizations_for user, page=nil
    user.visualizations.page(page).per(PAGE_SIZE)
  end

  def stories_for user, page=nil
    user.stories.page(page).per(PAGE_SIZE)
  end

end