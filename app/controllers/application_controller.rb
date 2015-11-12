class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Add agreement checkbox to sign_up form
  before_filter :update_sanitized_params, if: :devise_controller?
  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:agreement, :email, :password, :password_confirmation) }
  end
end
