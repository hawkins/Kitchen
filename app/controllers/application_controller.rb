class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    registration_params = [:name, :email, :password, :password_confirmation, :commit]

    if params[:action] == 'update'
      registration_params << :current_password
      devise_parameter_sanitizer.permit(:account_update, keys: registration_params)
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.permit(:sign_up, keys: registration_params)
    end
  end
end
