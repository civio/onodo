class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :gallery_editor_role?

  before_action :set_locale

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def gallery_editor_role?
    Gallery.instance.user_ids.include?(current_user.id)
  end

  def xhr_request?
    request.headers['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
  end

  def after_sign_in_path_for(resource)
    session[:user_return_to] || dashboard_path
  end
end
