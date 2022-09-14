class API::V1::StakesController < ApplicationController
  def create
    return render json: {error: "Not found."}, status: :not_found unless talent_token

    Stakes::Create.new(
      talent_token: talent_token,
      staking_user: current_user
    ).call

    render json: {success: "Stake created."}, status: :ok
  end

  def reward_claiming
    claimed_token = TalentToken.find_by(contract_id: stake_params[:token_id].downcase)

    return render json: {error: "Not found."}, status: :not_found unless claimed_token

    Stakes::RewardClaim.new(token: claimed_token).call

    render json: {success: "Rewards claimed successfuly."}, status: :ok
  end

  private

  def talent_token
    @talent_token ||= TalentToken.find_by(id: stake_params[:token_id])
  end

  def stake_params
    params.require(:stake).permit(
      :token_id
    )
  end
end
