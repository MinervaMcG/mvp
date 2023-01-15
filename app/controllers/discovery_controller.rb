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
    @discovery_row = DiscoveryRowBlueprint.render_as_json(discovery_row, view: :normal)
  end

  private

  def filter_params
    params.permit(:keyword, :status)
  end
end
