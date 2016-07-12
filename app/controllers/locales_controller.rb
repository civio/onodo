class LocalesController < ApplicationController
  # GET /locale/:locale
  def change_locale
    locale = params[:locale].downcase
    locale = I18n.default_locale unless I18n.locale_available? locale
    session[:locale] = locale
    @path = request.referer
    redirect_to normalized_path || root_path
  end

  private

  ROUTES_FOR_NEW = ['/visualizations', '/stories', '/chapters', '/nodes', '/relations']
  ROUTES_FOR_SIGN_UP = ['/users']

  def normalized_path
    return @path + '/new' if path_matches ROUTES_FOR_NEW
    return @path + '/sign_up' if path_matches ROUTES_FOR_SIGN_UP
    path
  end

  def path_matches routes_list
    routes_list.any?{ |r| @path.ends_with?(r) }
  end
end
