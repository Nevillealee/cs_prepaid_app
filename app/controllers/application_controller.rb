class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:admin])
  end
end
