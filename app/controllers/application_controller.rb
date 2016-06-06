class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def xhr_request?
    request.headers['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
  end

  private

  def after_sign_in_path_for(resource)
    session[:user_return_to] || dashboard_path
  end
end
