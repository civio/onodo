class RegistrationsController < Devise::RegistrationsController

  protected

  # Allow users to edit their account without providing a password 
  # (https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password)
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end