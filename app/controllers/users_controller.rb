class UsersController < ApplicationController

  # GET /user/:id
  def show
    @user = User.find(params[:id])
    if current_user.nil? 
      redirect_to '/login'
    elsif current_user != @user 
      redirect_to '/'
    end
  end

  # GET /user/:id/dashboard
  def dashboard

  end

  # GET /user/:id/settings
  def settings

  end
end