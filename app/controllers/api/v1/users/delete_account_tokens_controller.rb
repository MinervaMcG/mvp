class API::V1::Users::DeleteAccountTokensController < ApplicationController
  def create
    if user == current_user
      result = Users::CreateDeleteAccountToken.new(user: user).call
      if result[:success]
        render json: {success: "Delete account token created successfully"}, status: :created
      else
        render json: {error: "Unable to create delete account token"}, status: :unprocessable_entity
      end
    else
      render json: {error: "You don't have access to perform that action"}, status: :unauthorized
    end
  end

  private

  def user
    @user ||= User.find_by(id: params[:user_id])
  end
end
