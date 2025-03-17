class JwtDenylist
  include Mongoid::Document
  include Mongoid::Timestamps

  field :jti, type: String
  field :exp, type: Time

  # Index pour des recherches rapides
  index({ jti: 1 }, { unique: true })

  # Méthode requise par devise-jwt pour la stratégie de révocation
  def self.jwt_revoked?(payload, user)
    where(jti: payload['jti']).exists?
  end

  # Méthode requise par devise-jwt pour la stratégie de révocation
  def self.revoke_jwt(payload, user)
    create!(jti: payload['jti'], exp: Time.at(payload['exp'].to_i))
  rescue Mongoid::Errors::Validations => e
    Rails.logger.warn("JWT déjà révoqué: #{e.message}")
  end
end