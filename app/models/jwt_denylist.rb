class JwtDenylist
  include Mongoid::Document
  include Mongoid::Timestamps

  field :jti, type: String
  field :exp, type: Time

  # Index pour des recherches rapides
  index({ jti: 1 }, { unique: true })

  # Méthode requise par devise-jwt pour la stratégie de révocation
  def self.jwt_revoked?(payload, user)
    # Afficher des informations de débogage
    Rails.logger.debug "CHECKING REVOCATION FOR JTI: #{payload['jti']}"
    exists = where(jti: payload['jti']).exists?
    Rails.logger.debug "JTI REVOKED? #{exists}"
    exists
  end

  # Méthode requise par devise-jwt pour la stratégie de révocation
  def self.revoke_jwt(payload, user)
    Rails.logger.debug "REVOKING JTI: #{payload['jti']}"
    create!(jti: payload['jti'], exp: Time.at(payload['exp'].to_i))
    Rails.logger.debug "JTI SUCCESSFULLY REVOKED"
  rescue Mongoid::Errors::Validations => e
    Rails.logger.warn("JWT déjà révoqué: #{e.message}")
  end
end