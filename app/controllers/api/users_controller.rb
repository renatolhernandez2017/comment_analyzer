module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      username = user_params[:username]
      ImportUserDataService.new(username).call

      user = User.find_by(username: username)
      total = user.comments.count
      processed = user.comments.where.not(status: 'new').count
      progress = (processed.to_f / total * 100).round(2)

      progress = {
        user: user.username,
        total_comments: total,
        processed_comments: processed,
        progress: "#{(processed.to_f / total * 100).round(2)}%"
      }

      render json: { message: 'Usuário criado com sucesso!', user: user, progress: progress }, status: :created
    end

    private

    def user_params
      params.require(:user).permit(:username)
    end
  end
end
