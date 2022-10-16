class API::V1::Profile::Web3Controller < ApplicationController
  PER_PAGE = 3

  def update
    updated_token = Web3::UpdateToken.new(
      token: token,
      params: update_params
    ).call

    render json: render_token(updated_token), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Unable to update token with unexpected error.",
      token_id: token.id,
      user_id: user.id
    )
    render json: {error: "Something went wrong while updating the token"}, status: :bad_request
  end

  def tokens
    tokens = user.erc20_tokens
    tokens = tokens.visible if only_visible_tokens?
    tokens = tokens.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    @pagy, tokens = pagy(tokens.order_by_name, items: per_page)
    @tokens = Web3::Erc20TokenBlueprint.render_as_json(tokens, view: :normal)

    render(
      json: {
        tokens: @tokens,
        pagination: render_pagination(@pagy)
      },
      status: :ok
    )
  end

  def nfts
    nfts = user.erc721_tokens.nft
    nfts = nfts.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?
    nfts = nfts.visible if only_visible_tokens?

    @pagy, nfts = pagy(nfts.order_by_name, items: per_page)
    @nfts = Web3::Erc721TokenBlueprint.render_as_json(nfts, view: :normal)

    render(
      json: {
        tokens: @nfts,
        pagination: render_pagination(@pagy)
      },
      status: :ok
    )
  end

  def poaps
    poaps = user.erc721_tokens.poap
    poaps = poaps.visible if only_visible_tokens?

    @pagy, poaps = pagy(poaps.order_by_name, items: per_page)
    @poaps = Web3::Erc721TokenBlueprint.render_as_json(poaps, view: :normal)

    render(
      json: {
        tokens: @poaps,
        pagination: render_pagination(@pagy)
      },
      status: :ok
    )
  end

  def refresh_tokens
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "tokens", chain: refresh_params[:chain_id]).call

    tokens = current_acting_user.erc20_tokens
    tokens = tokens.visible if only_visible_tokens?
    tokens = tokens.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    pagy, tokens = pagy(tokens.order_by_name, items: per_page)
    tokens = Web3::Erc20TokenBlueprint.render_as_json(tokens, view: :normal)

    render(
      json: {
        tokens: tokens,
        pagination: render_pagination(pagy)
      },
      status: :ok
    )
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing tokens",
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while refreshing tokens. Try again later."}, status: :bad_request
  end

  def refresh_nfts
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "nfts", chain: refresh_params[:chain_id]).call

    nfts = current_acting_user.erc721_tokens.nft
    nfts = nfts.visible if only_visible_tokens?
    nfts = nfts.where(chain_id: refresh_params[:chain_id]) if refresh_params[:chain_id].present?

    @pagy, nfts = pagy(nfts.order_by_name, items: per_page)
    @nfts = Web3::Erc721TokenBlueprint.render_as_json(nfts, view: :normal)

    render(
      json: {
        tokens: @nfts,
        pagination: render_pagination(@pagy)
      },
      status: :ok
    )
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing nfts",
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while refreshing nfts. Try again later."}, status: :bad_request
  end

  def refresh_poaps
    Web3::RefreshUserTokens.new(user: current_acting_user, scope: "poaps").call

    poaps = current_acting_user.erc721_tokens.poap
    poaps = poaps.visible if only_visible_tokens?

    @pagy, poaps = pagy(poaps.order_by_name, items: per_page)
    @poaps = Web3::Erc721TokenBlueprint.render_as_json(poaps, view: :normal)

    render(
      json: {
        tokens: @poaps,
        pagination: render_pagination(@pagy)
      },
      status: :ok
    )
  rescue => e
    Rollbar.error(
      e,
      "Error while refreshing poaps",
      user_id: current_acting_user.id
    )
    render json: {error: "Something went wrong while refreshing poaps. Try again later."}, status: :bad_request
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def token
    @token ||= erc_20_token || erc_721_token
  end

  def erc_20_token
    current_acting_user.erc20_tokens.find_by(
      id: params[:id],
      chain_id: update_params[:chain_id],
      address: update_params[:address]
    )
  end

  def erc_721_token
    current_acting_user.erc721_tokens.find_by!(
      id: params[:id],
      chain_id: update_params[:chain_id],
      address: update_params[:address],
      token_id: update_params[:token_id]
    )
  end

  def update_params
    params.permit(:show, :chain_id, :address, :token_id, :image_url, :description, :name)
  end

  def refresh_params
    params.permit(:chain_id)
  end

  def per_page
    params[:per_page] || PER_PAGE
  end

  def only_visible_tokens?
    params.key?(:visible) && params[:visible]
  end

  def render_token(token)
    token.erc_20? ? Web3::Erc20TokenBlueprint.render(token, view: :normal) : Web3::Erc721TokenBlueprint.render(token, view: :normal)
  end

  def render_pagination(pagination)
    {
      totalItems: pagination.count,
      currentPage: pagination.page,
      lastPage: pagination.last,
      recordsPerPage: pagination.vars[:items]
    }
  end
end
