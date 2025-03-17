class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::MimeResponds

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, location: [:latitude, :longitude]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, location: [:latitude, :longitude]])
  end
end