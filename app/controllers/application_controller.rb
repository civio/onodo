class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :gallery_editor_role?

  before_action :check_demo_user
  before_action :set_locale

  private

  def check_demo_user
    sign_out(current_user) if (current_user == demo_user) && (params[:controller] !~ /^api\//) && !(params[:controller] == 'pages' && params[:action] == 'demo') && !(params[:controller] == 'nodes' && params[:action] == 'edit_description')
  end

  def set_locale
    I18n.locale = session[:locale] || http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
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

  def demo_user
    @@demo_user ||= User.find_by(name: 'demo')
  end
end
