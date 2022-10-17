class API::V1::Profile::CommunityController < ApplicationController
  PER_PAGE = 10

  def index
    connections = user.connections

    connections = connections.where(connection_type: search_params[:connection_type]) if search_by_connection_type?
    if search_by_keyword?
      connections = connections.joins(:connected_user)
        .where("users.username ILIKE :keyword OR users.display_name ILIKE :keyword", keyword: "%#{search_params[:community_q]}%")
    end

    connections = connections.includes(connected_user: {talent: :talent_token}).order(:connection_type)

    pagy, connections = pagy(connections.distinct, items: per_page)
    connections = CommunityConnectionBlueprint.render_as_json(connections, view: :normal)

    render(
      json: {
        connections: connections,
        pagination: render_pagination(pagy)
      },
      status: :ok
    )
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def per_page
    params[:per_page] || PER_PAGE
  end

  def search_params
    params.permit(:community_q, :connection_type)
  end

  def search_by_connection_type?
    search_params[:connection_type].present?
  end

  def search_by_keyword?
    search_params[:community_q].present?
  end
end
