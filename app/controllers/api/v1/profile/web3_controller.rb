class API::V1::Profile::Web3Controller < ApplicationController
  def update
    token.update!(show: !token.show)
    render json: {success: "Token successfully updated"}, status: :created
  rescue => e
    Rollbar.error(
      e,
      "Unable to update token with unexpected error.",
      token_id: token.id,
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while updating the token"}, status: :bad_request
  end

  def tokens
    tokens = current_acting_user.erc20_tokens
    tokens = tokens.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc20TokenBlueprint.render(tokens, view: :normal), status: :ok
  end

  def nfts
    nfts = current_acting_user.erc721_tokens.nft
    nfts = nfts.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc721TokenBlueprint.render(nfts, view: :normal), status: :ok
  end

  def poaps
    poaps = current_acting_user.erc721_tokens.poap
    poaps = poaps.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc721TokenBlueprint.render(poaps, view: :normal), status: :ok
  end

  def refresh_tokens
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "tokens", chain: refresh_params[:chain_id]).call

    tokens = current_acting_user.erc20_tokens
    tokens = tokens.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc20TokenBlueprint.render(tokens, view: :normal), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing tokens",
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while refreshing tokens"}, status: :bad_request
  end

  def refresh_nfts
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "nfts", chain: refresh_params[:chain_id]).call

    nfts = current_acting_user.erc721_tokens.nft
    nfts = nfts.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc721TokenBlueprint.render(nfts, view: :normal), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing nfts",
      user_id: user.id
    )
    render json: {error: "Something went wrong while refreshing nfts"}, status: :bad_request
  end

  def refresh_poaps
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "poaps").call

    poaps = current_acting_user.erc721_tokens.poap
    poaps = poaps.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    render json: Web3::Erc721TokenBlueprint.render(poaps, view: :normal), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing poaps",
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while refreshing poaps"}, status: :bad_request
  end

  private

  def token
    @token ||= erc_20_token || erc_721_token
  end

  def erc_20_token
    current_acting_user.erc20_tokens.find_by(
      id: params[:token_id],
      chain_id: update_params[:chain_id],
      address: update_params[:address]
    )
  end

  def erc_721_token
    current_acting_user.erc721_tokens.find_by!(
      id: params[:token_id],
      chain_id: update_params[:chain_id],
      address: update_params[:address]
    )
  end

  def update_params
    params.permit(:chain_id, :address)
  end

  def refresh_params
    params.permit(:chain_id)
  end
end
