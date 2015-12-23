class UsersController < ApplicationController

  # GET /user/:id
  def show
    @user = User.find(params[:id])
    @items = Visualization.where(author_id: params[:id])
    @items = @items.page(params[:page]).per(2)
    @visualizations = true
    #@visualizations = Visualization.where(author_id: params[:id])
    #@stories = Story.where(author_id: params[:id])
  end

  # GET /user/:id/settings
  def settings

  end
end