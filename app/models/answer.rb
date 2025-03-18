
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String

  # Relations
  belongs_to :user
  belongs_to :question

  # Validations
  validates :content, presence: true

  # Méthode pour la sérialisation JSON
  def as_json(options = {})
    super(options.merge(
      include: {
        user: { only: [:id, :name, :email] }
      }
    ))
  end
end