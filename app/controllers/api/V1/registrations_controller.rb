module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      # Intercepter la requête pour réorganiser les paramètres
      def create
        # Si les paramètres ne sont pas sous la clé :user, les réorganiser
        if params[:email].present? && !params[:user].present?
          params_to_add = params.permit(:email, :password, :password_confirmation, :name, location: [:latitude, :longitude]).to_h
          params[:user] = params_to_add
        end
        super
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: 'Inscrit avec succès.' },
            data: { user: resource }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: "L'utilisateur n'a pas pu être créé. #{resource.errors.full_messages.join(', ')}" }
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name, location: [:latitude, :longitude])
      end
    end
  end
end