class UsersController < ApplicationController

  PAGE_SIZE = 4

  # GET /users/:id
  def show
    @user = user_for params[:id]
    # Get published visualizations from user
    @items = visualizations_for @user, true, params[:page]
    @visualizations = true
    render :show
  end

  # GET /users/:id/visualizations
  alias_method :show_visualizations, :show

  # GET /users/:id/stories
  def show_stories
    @user = user_for params[:id]
    @items = stories_for @user, true, params[:page]
    render :show
  end

  # GET /dashboard
  def show_dashboard
    return unless current_user
    @user = current_user
    # Get all visualizations from user
    @items = visualizations_for @user, false, params[:page]
    @visualizations = true
    render :show
  end

  # GET /dashboard/visualizations
  alias_method :show_dashboard_visualizations, :show_dashboard

  # GET /dashboard/stories
  def show_dashboard_stories
    return unless current_user
    @user = current_user
    @items = stories_for @user, false, params[:page]
    render :show
  end

  private

  def user_for user_id
    User.find(user_id)
  end

  def visualizations_for user, published, page=nil
    if published
      user.visualizations.published.page(page).per(PAGE_SIZE)
    else
      user.visualizations.page(page).per(PAGE_SIZE)
    end  
  end

  def stories_for user, published, page=nil
    if published
      user.stories.published.page(page).per(PAGE_SIZE)
    else
      user.stories.page(page).per(PAGE_SIZE)
    end
  end

end