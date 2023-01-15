class ProfilesController < ApplicationController
  def show
    # Done this way so we can eager load all the images
    talent =
      Talent
        .includes([career_goal: {goals: :goal_images}, milestones: :milestone_images])
        .find_by!(user: user)

    CreateProfilePageVisitorJob.perform_later(ip: request.remote_ip, user_id: user.id)

    @talent = TalentBlueprint.render_as_json(
      talent,
      view: :extended,
      current_user_watchlist: current_user_watchlist,
      tags: user.tags.where(hidden: false)
    )

    @with_persona_request = WithPersonaRequestBlueprint.render_as_json(WithPersonaRequest.current_month_persona_request)
  end

  private

  def user
    @user ||= User.find_by!("username=? or wallet_id=? or ens_domain=?", params[:username], params[:username].downcase, params[:username])
  end
end
