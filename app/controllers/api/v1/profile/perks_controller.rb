class API::V1::Profile::PerksController < ApplicationController
  PER_PAGE = 10

  def index
    talent = user.talent

    return render(json: {message: "Talent does not exist."}, status: :not_found) unless talent

    perks = PerkBlueprint.render_as_json(talent.perks)

    render(
      json: {
        perks: perks
      },
      status: :ok
    )
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end
end
