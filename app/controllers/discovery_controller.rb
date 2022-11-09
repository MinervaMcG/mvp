class DiscoveryController < ApplicationController
  def index
    @discovery_rows = DiscoveryRowBlueprint.render_as_json(
      DiscoveryRow.all.includes(:visible_tags, :partnership),
      view: :normal
    )

    marketing_articles = MarketingArticle.all.order(created_at: :desc).limit(3)
    @marketing_articles = MarketingArticleBlueprint.render_as_json(marketing_articles, view: :normal)
  end

  def show
    discovery_row = DiscoveryRow.find_by!(slug: params[:slug])

    service = Talents::Search.new(filter_params: filter_params.to_h, discovery_row: discovery_row)
    talents = service.call

    @discovery_row = DiscoveryRowBlueprint.render_as_json(discovery_row, view: :normal)
    @talents = TalentBlueprint.render_as_json(talents.includes(:user, :talent_token), view: :normal, current_user_watchlist: current_user_watchlist)

    respond_to do |format|
      format.html
      format.json {
        render(
          json: @talents,
          status: :ok
        )
      }
    end
  end

  private

  def filter_params
    params.permit(:keyword, :status)
  end
end
