# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authorize_admin, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  # prevents already signed in error when creating user as admin user
  # skip_before_action :require_no_authentication
  # overwrites Devise helper method so that new user isnt automatically signed in
  # def sign_up(resource_name, resource)
  #   true
  # end

  protected
  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :password_confirmation, :admin])
  end

  def authorize_admin
    return unless !current_user.try(:admin?)
    redirect_to root_path, alert: 'Admins permissions insufficient'
  end
end
