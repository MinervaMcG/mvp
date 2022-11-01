class TalentController < ApplicationController
  PER_PAGE = 40

  def index
    @paging, @talents = Talents::ChewySearch.new(filter_params: filter_params.to_h, admin: current_user.admin?, size: per_page, from: ((params[:page] || "1").to_i - 1) * per_page).call
    # @pagy, talents = pagy(service.call, items: per_page)

    # @talents = TalentBlueprint.render_as_json(talents.includes(:talent_token, user: :investor), view: :normal, current_user_watchlist: current_user_watchlist)

    respond_to do |format|
      format.html
      format.json {
        render(
          json: {
            talents: @talents,
            pagination: @paging
          },
          status: :ok
        )
      }
    end
  end

  private

  def filter_params
    params.permit(:keyword, :status)
  end

  def per_page
    params[:per_page] || PER_PAGE
  end
end
