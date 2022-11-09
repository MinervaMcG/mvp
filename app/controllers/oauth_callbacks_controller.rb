# frozen_string_literal: true

class OauthCallbacksController < ApplicationController
  def linkedin
    result = Linkedin::OauthHandler.new(code: params[:code]).call
    if result[:success]
      sign_in(result[:user])
      redirect_to root_path
    else
      redirect_to root_path, flash: {error: "Failed LinkedIn login"}
    end
  end

  def unstoppable_domains
    user = UnstoppableDomains::LoginUser.new(unstoppable_domains_params.to_h).call
    sign_in(user)
    render json: {username: user.username}, status: :ok
  rescue UnstoppableDomains::LoginUser::WalletVerificationError => error
    render json: {error: error.message}, status: :bad_request
  rescue UnstoppableDomains::LoginUser::UserCreationError => error
    Rollbar.error(
      error,
      "Error logging with unstoppable domains",
      unstoppable_domains_params
    )
    render json: {error: error.message}, status: :bad_request
  rescue => error
    Rollbar.error(
      error,
      "Error logging with unstoppable domains",
      unstoppable_domains_params
    )
    render json: {error: "Something went wrong. Our team was notified and will check the issue soon. #{error.message}"}, status: :bad_request
  end

  private

  def unstoppable_domains_params
    params.permit(
      :wallet_address,
      :eip4361_message,
      :eip4361_signature,
      :picture,
      :name,
      :email,
      :ipfs_website,
      twitter: {}
    )
  end
end
