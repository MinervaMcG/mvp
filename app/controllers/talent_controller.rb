class TalentController < ApplicationController
  PER_PAGE = 40
  PAGE_NEUTRALIZER = 1

  def index
    @paging, @talents = Talents::ChewySearch.new(filter_params: filter_params.to_h, admin_or_moderator: current_user.admin_or_moderator?, size: per_page, from: ((params[:page] || PAGE_NEUTRALIZER).to_i - PAGE_NEUTRALIZER) * per_page, current_user_watchlist: current_user_watchlist).call

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
    (params[:per_page] || PER_PAGE).to_i
  end
end
