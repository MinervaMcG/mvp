class API::V1::UsernamesController < ApplicationController
  TAKEN_ERROR_MESSAGE = "Username already taken.".freeze
  INVALID_ERROR_MESSAGE = "Username only allows lower case letters and numbers.".freeze

  def valid
    render json: {error: error_message}, status: :ok
  end

  private

  def error_message
    message = ""
    message += TAKEN_ERROR_MESSAGE if username_taken?
    message += INVALID_ERROR_MESSAGE unless valid?

    message
  end

  def username_taken?
    User.where.not(id: current_user&.id).where(username: params[:username]).any?
  end

  def valid?
    User.valid_username?(params[:username])
  end
end
