Rails.application.routes.draw do
  get 'test/mongo', to: 'test#index'

  # Routes API avec versionnement
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/sessions',
        registrations: 'api/v1/registrations'
      }, path: '', path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        registration: 'signup'
      }
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  get "ping" => "application#ping"
end