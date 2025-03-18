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

  # Hook pour assurer le format GeoJSON
  before_save :ensure_geojson_format

  # Index pour la géolocalisation
  index({ location: "2dsphere" })

  # Méthodes
  def location_coordinates
    [location['longitude'], location['latitude']] if location.present?
  end

  # Calculer la distance entre cette question et les coordonnées données
  def distance_to(coords)
    return nil unless coords.present? && location.present?

    begin
      # Si location est au format GeoJSON
      if location['type'].present? && location['coordinates'].present?
        long = location['coordinates'][0]
        lat = location['coordinates'][1]
        Geocoder::Calculations.distance_between(
          [lat, long],
          [coords['latitude'], coords['longitude']]
        )
      else
        # Fallback pour l'ancien format
        Geocoder::Calculations.distance_between(
          [location['latitude'], location['longitude']],
          [coords['latitude'], coords['longitude']]
        )
      end
    rescue => e
      Rails.logger.error("Erreur dans le calcul de distance: #{e.message}")
      nil
    end
  end

  # Méthode pour les requêtes géospatiales
  def self.near(coords, distance_in_km = 10)
    where(location: {
      '$near' => {
        '$geometry' => {
          'type' => "Point",
          'coordinates' => [coords['longitude'].to_f, coords['latitude'].to_f]
        },
        '$maxDistance' => distance_in_km * 1000
      }
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

  private

  def ensure_geojson_format
    if location.present? && !location['type'].present?
      self.location = {
        'type' => 'Point',
        'coordinates' => [location['longitude'].to_f, location['latitude'].to_f]
      }
    end
  end
end