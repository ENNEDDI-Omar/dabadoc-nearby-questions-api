class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :title, type: String
  field :content, type: String
  field :location, type: Hash
  field :favorites_count, type: Integer, default: 0

  # Relations
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :favorites, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :location, presence: true

  # Géolocalisation
  geocoded_by :location_coordinates

  # Index pour la géolocalisation
  index({ location: "2dsphere" })

  # Méthodes
  def location_coordinates
    [location['longitude'], location['latitude']] if location.present?
  end

  # Calculer la distance entre cette question et les coordonnées données
  def distance_to(coords)
    return nil unless coords.present? && location.present?

    Geocoder::Calculations.distance_between(
      [location['latitude'], location['longitude']],
      [coords['latitude'], coords['longitude']]
    )
  end

  # Méthode pour les requêtes géospatiales
  def self.near(coords, distance_in_km = 10)
    where(:location.near => {
      :geometry => {
        :type => "Point",
        :coordinates => [coords['longitude'].to_f, coords['latitude'].to_f]
      },
      :max_distance => distance_in_km * 1000,
      :spherical => true
    })
  end

  # Méthode pour la sérialisation JSON
  def as_json(options = {})
    super(options.merge(
      include: {
        user: { only: [:id, :name, :email] }
      },
      methods: [:answers_count]
    ))
  end

  def favorites_count
    favorites.count
  end

  def answers_count
    answers.count
  end
end