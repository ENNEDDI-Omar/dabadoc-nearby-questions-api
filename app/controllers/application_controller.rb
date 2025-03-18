class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::MimeResponds
  include Devise::Controllers::Helpers
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Dans ApplicationController
  def authenticate_api_user!
    begin
      token = request.headers['Authorization']&.split(' ')&.last
      if token
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
        user_id = decoded_token.first['sub']
        @current_user = User.find(user_id)
      else
        render json: { error: "Token d'authentification manquant" }, status: :unauthorized
      end
    rescue JWT::DecodeError, JWT::VerificationError
      render json: { error: "Token d'authentification invalide" }, status: :unauthorized
    rescue Mongoid::Errors::DocumentNotFound
      render json: { error: "Utilisateur non trouvé" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  # Remplacez authenticate_user! dans vos contrôleurs par authenticate_api_user!

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, location: [:latitude, :longitude]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, location: [:latitude, :longitude]])
  end
end