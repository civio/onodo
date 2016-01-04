class UsersController < ApplicationController

  # GET /users/:id
  # GET /users/:id/visualizations
  def show
    @user = User.find(params[:id])
    @items = Visualization.where(author_id: params[:id])
    @items = @items.page(params[:page]).per(2)
    @visualizations = true
    render :show
  end

  # GET /users/:id/stories
  def show_stories
    @user = User.find(params[:id])
    @items = Story.where(author_id: params[:id])
    @items = @items.page(params[:page]).per(2)
    render :show
  end

  # GET /users/:id/settings
  def settings

  end
end