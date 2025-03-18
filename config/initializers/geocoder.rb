# config/initializers/geocoder.rb
Geocoder.configure(
  # Options de géocoder
  timeout: 5,                 # Timeout pour les requêtes HTTP
  lookup: :nominatim,         # Service de geocoding (OpenStreetMap)
  use_https: true,            # HTTPS par défaut
  units: :km,                 # Unité par défaut: kilomètres
  distances: :spherical,      # Méthode de calcul de distance: sphérique
  always_raise: :all,         # Lever des exceptions pour toutes les erreurs
  maxmind: {                  # Configurer votre service
                              service: :geoip2,
                              file: nil,
                              country: 'GeoLite2-Country.mmdb',
                              city: 'GeoLite2-City.mmdb'
  }
)