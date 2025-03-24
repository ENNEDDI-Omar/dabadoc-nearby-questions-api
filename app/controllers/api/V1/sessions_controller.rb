module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        # Parameter normalization
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

        begin
          self.resource = warden.authenticate!(auth_options)
          sign_in(resource_name, resource)

          token = request.env['warden-jwt_auth.token']

          render json: {
            status: { code: 200, message: 'Successfully logged in.' },
            data: {
              user: resource,
              token: token
            }
          }, status: :ok
        rescue Warden::AuthenticationError => e
          Rails.logger.debug "Authentication Error: #{e.message}"
          render json: {
            status: { code: 401, message: 'Invalid email or password.' }
          }, status: :unauthorized
        rescue => e
          Rails.logger.debug "General Error: #{e.message}"
          render json: {
            status: { code: 500, message: "Authentication error: #{e.message}" }
          }, status: :internal_server_error
        end
      end

      private

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
              message: "Successfully logged out."
            }, status: :ok
          else
            render json: {
              status: 401,
              message: "Token not found."
            }, status: :unauthorized
          end
        rescue JWT::DecodeError, JWT::VerificationError
          render json: {
            status: 401,
            message: "Invalid or expired token."
          }, status: :unauthorized
        rescue StandardError => e
          render json: {
            status: 500,
            message: "Error: #{e.message}"
          }, status: :internal_server_error
        end
      end
    end
  end
end