class API::V1::UsersController < ApplicationController
  def index
    @users = search_params[:name].present? ? filtered_users : filtered_users.limit(20)

    render json: {
      users: @users.includes(talent: :talent_token).map { |u|
        {
          id: u.id,
          profilePictureUrl: u&.profile_picture_url,
          username: u.username,
          ticker: u.talent&.talent_token&.display_ticker
        }
      }
    }, status: :ok
  end

  # Public endpoint
  def show
    @user = User.find_by(wallet_id: params[:id])

    if @user
      render json: {
        id: @user.id,
        profilePictureUrl: @user&.profile_picture_url,
        username: @user.username,
        messagingDisabled: @user.messaging_disabled
      }, status: :ok
    else
      render json: {error: "Not found."}, status: :not_found
    end
  end

  def update
    if user.nil? || current_user.nil? || user.id != current_user.id
      return render json: {error: "You don't have access to perform that action"}, status: :unauthorized
    end

    render json: {error: "Not found."}, status: :not_found unless user

    result = Users::Update.new(
      user: user,
      user_params: user_params.to_h,
      password_params: password_params.to_h,
      tal_domain: tal_domain,
      wallet_id: params[:wallet_id],
      first_quest_popup: params[:first_quest_popup]
    ).call

    unless result[:success]
      return render json: {errors: result[:errors]}, status: :conflict
    end

    render json: result[:user], status: :ok
  end

  private

  def user
    @user ||= User.find_by(id: params[:id])
  end

  def search_params
    params.permit(:name, :messaging_disabled)
  end

  def user_params
    params.require(:user).permit(
      :theme_preference, :username, :email, :messaging_disabled, :display_name,
      notification_preferences: {}
    )
  end

  def tal_domain
    params.require(:user).permit(:tal_domain)[:tal_domain]
  end

  def password_params
    params.require(:user).permit(:new_password, :current_password)
  end

  def filtered_users
    Users::Search.new(
      current_user: current_user,
      search_params: search_params.to_h
    ).call
  end
end
