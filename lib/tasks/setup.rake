
namespace :db do
  desc "Setup database indexes"
  task setup_indexes: :environment do
    Mongoid.client(:default).collections.each do |collection|
      collection.indexes.drop_all
    end

    # Index pour Geocoder sur le modèle Question
    Question.create_indexes
    User.create_indexes
    Favorite.create_indexes
    puts "Indexes created successfully"
  end
end