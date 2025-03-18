
class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relations
  belongs_to :user
  belongs_to :question

  # Validation pour éviter les doublons
  validates :user_id, uniqueness: { scope: :question_id }

  # Index pour les requêtes
  index({ user_id: 1, question_id: 1 }, { unique: true })
end