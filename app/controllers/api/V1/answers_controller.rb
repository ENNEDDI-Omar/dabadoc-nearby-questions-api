# app/controllers/api/v1/answers_controller.rb
module Api
  module V1
    class AnswersController < BaseController
      before_action :set_question
      before_action :set_answer, only: [:update, :destroy]
      skip_before_action :authenticate_api_user!, only: [:index]

      # GET /api/v1/questions/:question_id/answers
      def index
        @answers = @question.answers.order_by(created_at: :desc)
        render json: @answers
      end

      # POST /api/v1/questions/:question_id/answers
      def create
        @answer = @question.answers.new(answer_params)
        @answer.user = current_user

        if @answer.save
          render json: @answer, status: :created
        else
          render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/questions/:question_id/answers/:id
      def update
        if @answer.user_id != current_user.id
          return render json: { error: "Vous n'êtes pas autorisé à modifier cette réponse" }, status: :forbidden
        end

        if @answer.update(answer_params)
          render json: @answer
        else
          render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/questions/:question_id/answers/:id
      def destroy
        if @answer.user_id != current_user.id
          return render json: { error: "Vous n'êtes pas autorisé à supprimer cette réponse" }, status: :forbidden
        end

        @answer.destroy
        head :no_content
      end

      private

      def set_question
        @question = Question.find(params[:question_id])
      end

      def set_answer
        @answer = @question.answers.find(params[:id])
      end

      def answer_params
        params.require(:answer).permit(:content)
      end
    end
  end
end