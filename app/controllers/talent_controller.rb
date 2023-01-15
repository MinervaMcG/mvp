class TalentController < ApplicationController
  PER_PAGE = 40
  PAGE_NEUTRALIZER = 1

  def index
  end

  private

  def filter_params
    params.permit(:keyword, :status)
  end

  def per_page
    (params[:per_page] || PER_PAGE).to_i
  end
end
