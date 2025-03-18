module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        if params[:session] && params[:session][:user]
          params[:user] = params[:session][:user]
        elsif params[:session] && params[:session][:email] && params[:session][:password]
          params[:user] = {
            email: params[:session][:email],
            password: params[:session][:password]
          }
        elsif params[:email] && params[:password] && !params[:user]
          params[:user] = {
            email: params[:email],
            password: params[:password]
          }
        end

        Rails.logger.debug "REFORMATTED LOGIN ATTEMPT: #{params.inspect}"
        super
      end

      private



      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Connecté avec succès.' },
          data: { user: resource }
        }, status: :ok
      end

      def respond_to_on_destroy
        begin
          if request.headers['Authorization'].present?
            jwt_token = request.headers['Authorization'].split(' ')[1]

            jwt_payload = JWT.decode(
              jwt_token,
              Rails.application.credentials.secret_key_base,
              true,
              { algorithm: 'HS256' }
            ).first

            jti = jwt_payload['jti']
            JwtDenylist.create!(jti: jti, exp: Time.at(jwt_payload['exp'].to_i))

            render json: {
              status: 200,
              message: "Déconnecté avec succès."
            }, status: :ok
          else
            render json: {
              status: 401,
              message: "Token non trouvé."
            }, status: :unauthorized
          end
        rescue JWT::DecodeError, JWT::VerificationError
          render json: {
            status: 401,
            message: "Token invalide ou expiré."
          }, status: :unauthorized
        rescue StandardError => e
          render json: {
            status: 500,
            message: "Erreur: #{e.message}"
          }, status: :internal_server_error
        end
      end
    end
  end
end