# app/controllers/api/v1/questions_controller.rb
module Api
  module V1
    class QuestionsController < BaseController
      before_action :set_question, only: [:show, :update, :destroy]
      skip_before_action :authenticate_user!, only: [:index, :show]

      # GET /api/v1/questions
      def index
        if params[:lat].present? && params[:lng].present?
          coords = { 'latitude' => params[:lat].to_f, 'longitude' => params[:lng].to_f }
          distance = params[:distance].present? ? params[:distance].to_i : 10 # default 10km
          @questions = Question.near(coords, distance).order_by(created_at: :desc)
        else
          @questions = Question.all.order_by(created_at: :desc)
        end

        # Ajouter la distance pour chaque question si des coordonnées sont fournies
        if params[:lat].present? && params[:lng].present?
          user_coords = { 'latitude' => params[:lat].to_f, 'longitude' => params[:lng].to_f }
          @questions = @questions.map do |q|
            q.attributes.merge('distance' => q.distance_to(user_coords))
          end

          # Trier par distance si demandé
          if params[:sort] == 'distance'
            @questions = @questions.sort_by { |q| q['distance'] || Float::INFINITY }
          end
        end

        render json: @questions
      end

      # GET /api/v1/questions/:id
      def show
        render json: @question
      end

      # POST /api/v1/questions
      def create
        @question = current_user.questions.new(question_params)

        if @question.save
          render json: @question, status: :created
        else
          render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/questions/:id
      def update
        if @question.user_id != current_user.id
          return render json: { error: "Vous n'êtes pas autorisé à modifier cette question" }, status: :forbidden
        end

        if @question.update(question_params)
          render json: @question
        else
          render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/questions/:id
      def destroy
        if @question.user_id != current_user.id
          return render json: { error: "Vous n'êtes pas autorisé à supprimer cette question" }, status: :forbidden
        end

        @question.destroy
        head :no_content
      end

      private

      def set_question
        @question = Question.find(params[:id])
      end

      def question_params
        params.require(:question).permit(:title, :content, location: [:latitude, :longitude])
      end
    end
  end
end