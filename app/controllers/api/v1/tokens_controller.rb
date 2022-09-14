class API::V1::TokensController < ApplicationController
  def show
    if talent_token
      render json: {
        id: talent_token.id,
        address: talent_token.contract_id,
        profilePictureUrl: talent_token.talent.profile_picture_url,
        variance7d: talent_token.variance7d.round(2).to_s(:delimited)
      }, status: :ok
    else
      render json: {error: "Not found."}, status: :not_found
    end
  end

  private

  def talent_token
    @talent_token ||= TalentToken.find_by(contract_id: params[:id])
  end
end
