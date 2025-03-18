class User
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.primary_key
    '_id'
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Custom fields for our application
  field :name, type: String
  field :location, type: Hash

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  ## Relations avec les autres modèles
  #has_many :questions, dependent: :destroy
  #has_many :answers, dependent: :destroy
  #has_many :favorites, dependent: :destroy
  #has_many :favorite_questions, through: :favorites, source: :question

  ## Index pour améliorer les performances de recherche
  index({ email: 1 }, { unique: true })

  ## Méthodes personnalisées
   # Récupérer toutes les questions favorites de l'utilisateur
      #def favorite_questions
        #Question.where(:id.in => favorites.pluck(:question_id))
      #end
  # Methods pour rendre l'utilisateur sérialisable en JSON
    def as_json(options = {})
      super(options.merge({ except: [:encrypted_password, :reset_password_token] }))
    end


  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

end
