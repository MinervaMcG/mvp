class ProfilesController < ApplicationController
  def show
    talent = user.talent

    CreateProfilePageVisitorJob.perform_later(ip: request.remote_ip, user_id: user.id)

    @talent = TalentBlueprint.render_as_json(
      talent,
      view: :extended,
      current_user_watchlist: current_user_watchlist,
      tags: user.tags.where(hidden: false)
    )
  end

  private

  def user
    @user ||= User.find_by!("username=? or wallet_id=? or ens_domain=?", params[:username], params[:username].downcase, params[:username])
  end
end
