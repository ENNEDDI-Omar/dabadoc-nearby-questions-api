
module Api
  module V1
    class FavoritesController < BaseController
      before_action :set_question, only: [:create, :destroy]

      # GET /api/v1/favorites
      def index
        @favorite_questions = current_user.favorite_questions
        render json: @favorite_questions
      end

      # POST /api/v1/questions/:question_id/favorites
      def create
        @favorite = current_user.favorites.new(question: @question)

        if @favorite.save
          render json: { message: "Question ajoutée aux favoris", question_id: @question.id }, status: :created
        else
          render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/questions/:question_id/favorites
      def destroy
        @favorite = current_user.favorites.find_by(question_id: @question.id)

        if @favorite.nil?
          render json: { error: "Favori non trouvé" }, status: :not_found
        else
          @favorite.destroy
          render json: { message: "Question retirée des favoris", question_id: @question.id }, status: :ok
        end
      end

      private

      def set_question
        @question = Question.find(params[:question_id])
      end
    end
  end
end