Rails.application.routes.draw do
  resources :questions
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

      # Routes pour les questions, réponses et favoris
      resources :questions do
        resources :answers, only: [:index, :create, :update, :destroy]
        resource :favorites, only: [:create, :destroy]
      end

      # Route pour les questions favorites
      get 'favorites', to: 'favorites#index'
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  get "ping" => "application#ping"
end