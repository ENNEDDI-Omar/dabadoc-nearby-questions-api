module Api
  module V1
    class BaseController < ApplicationController
      include ActionController::MimeResponds
      include Devise::Controllers::Helpers
      before_action :authenticate_api_user!

      rescue_from StandardError, with: :handle_error

      private

      def handle_error(error)
        case error
        when Mongoid::Errors::DocumentNotFound
          render json: { error: "Ressource non trouvée" }, status: :not_found
        else
          render json: { error: error.message }, status: :unprocessable_entity
        end
      end
    end
  end
end