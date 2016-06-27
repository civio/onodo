class RegistrationsController < Devise::RegistrationsController

  def update
    begin
      super
    # needed to manage responses to dropzone XHR submissions
    rescue ActionController::UnknownFormat
      render json: { location: after_update_path_for(resource) } and return if xhr_request?
    end
  end

  protected

  # Allow users to edit their account without providing a password 
  # (https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password)
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    dashboard_path
  end

  # Add custom fields to registration
  # http://jacopretorius.net/2014/03/adding-custom-fields-to-your-devise-user-model-in-rails-4.html

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :terms_of_service)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :website, :facebook, :twitter, :avatar, :avatar_cache)
  end

end
