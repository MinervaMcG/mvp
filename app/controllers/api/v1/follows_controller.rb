class API::V1::FollowsController < ApplicationController
  def index
    @follows = current_user.follows
    @following = current_user.following
  end

  def create
    Follows::Create.new(follower_user: current_user, following_user: following_user).call

    render json: {success: "Follow successfully created."}, status: :created
  rescue Follows::Create::AlreadyExistsError
    render json: {error: "Already following."}, status: :conflict
  rescue Follows::Create::CreationError => error
    Rollbar.error(error, "Error creating follow", current_user_id: current_user.id, following_user_id: following_user.id)
    render json: {error: "Unable to create follow."}, status: :bad_request
  end

  def destroy
    follow = Follow.find_by!(user: following_user, follower: current_user)

    Follows::Destroy.new(follow: follow).call

    render json: {success: "Follow successfully removed."}, status: :ok
  rescue Follows::Destroy::DestroyError => error
    Rollbar.error(error, "Error destroying follow", current_user_id: current_user.id, following_user_id: following_user.id, follow_id: follow.id)
    render json: {error: "Unable to remove follow."}, status: :bad_request
  end

  private

  def follow_params
    params.permit(:user_id)
  end

  def following_user
    @following_user ||= User.find(follow_params[:user_id])
  end
end
