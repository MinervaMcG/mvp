class SessionsController < Clearance::SessionsController
  protect_from_forgery

  def create
    email = params[:session][:email]

    if User.find_by(email: email&.downcase)
      @user = authenticate(params)

      if @user&.disabled?
        alert = "Your account has been disabled, reach out to us if you think this is a mistake."
        render json: {error: alert}, status: :unauthorized
      else
        sign_in(@user) do |status|
          if status.success?
            render json: {}, status: :ok
          else
            render json: {error: "wrong email or password"}, status: :unauthorized
          end
        end
      end
    else
      render json: {error: "wrong email or password"}, status: :unauthorized
    end
  end

  def destroy
    cookies.delete :impersonated
    sign_out
  end

  def new
    if profile_subdomain?
      return redirect_to "https://beta.talentprotocol.com/" unless tal_domain

      user = tal_domain.user

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

      return render "profiles/show"
    end

    render template: "sessions/new"
  end

  private

  def profile_subdomain?
    request.domain == ENV["TAL_BASE_DOMAIN"]
  end

  def tal_domain
    @tal_domain ||= UserDomain.where(tal_domain: true).find_by("domain = ?", request.subdomain)
  end

  def user
    @user ||= User.find_by("username=:subdomain or wallet_id=:subdomain or ens_domain=:subdomain", subdomain: request.subdomain)
  end

  def profile_subdomain
    @profile_subdomain ||= request.subdomain
  end
end
