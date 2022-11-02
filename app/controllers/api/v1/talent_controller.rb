class API::V1::TalentController < ApplicationController
  PER_PAGE = 40
  PAGE_NEUTRALIZER = 1

  def index
    # service = Talents::Search.new(filter_params: filter_params.to_h, admin: current_user.admin?)
    # pagy, talents = pagy(service.call, items: per_page)

    # talents = TalentBlueprint.render_as_json(talents.includes(:talent_token), view: :normal, current_user_watchlist: current_user_watchlist)

    # render json: {
    #   talents: talents,
    #   pagination: {
    #     currentPage: pagy.page,
    #     lastPage: pagy.last
    #   }
    # }, status: :ok

    paging, talents = Talents::ChewySearch.new(filter_params: filter_params.to_h, admin: current_user.admin?, size: per_page, from: ((params[:page] || PAGE_NEUTRALIZER).to_i - PAGE_NEUTRALIZER) * per_page, current_user_watchlist: current_user_watchlist).call
    render json: {talents: talents, pagination: paging}, status: :ok
  end

  # public /
  def public_index
    talents =
      if token_id_params.present?
        Talent.includes(:talent_token, :user).where(talent_tokens: {contract_id: token_id_params})
      else
        []
      end

    render json: TalentBlueprint.render(talents, view: :normal, current_user_watchlist: current_user_watchlist), status: :ok
  end

  # Public endpoint
  def show
    talent = Talent.joins(:talent_token).find_by(talent_tokens: {contract_id: params[:id]})

    if talent
      render json: TalentBlueprint.render(talent, view: :normal, current_user_watchlist: current_user_watchlist), status: :ok
    else
      render json: {error: "Not found."}, status: :not_found
    end
  end

  def update
    if !current_user.admin? && !current_user.moderator? && talent.id != current_acting_user.talent&.id
      return render json: {error: "You don't have access to perform that action"}, status: :unauthorized
    end

    service = API::UpdateTalent.new(talent, current_user)
    service.call(talent_params, user_params, tag_params, career_need_params)

    if service.success
      CreateNotificationTalentChangedJob.perform_later(talent.user.followers.pluck(:follower_id), talent.user_id)
      render json: TalentBlueprint.render(talent, view: :extended, current_user_watchlist: current_user_watchlist), status: :ok
    else
      render json: {error: "Unable to update Talent."}, status: :unprocessable_entity
    end
  end

  private

  def talent
    @talent ||=
      if talent_id_param
        Talent.find(params[:id])
      else
        Talent.find_by!(public_key: params[:talent_id])
      end
  end

  def token_id_params
    params.require(:tokens)
  end

  def filter_params
    params.permit(:keyword, :status, :discovery_row_id, :watchlist_only)
  end

  def discovery_row
    DiscoveryRow.find_by(id: filter_params[:discovery_row_id])
  end

  def user_params
    params.require(:user).permit(
      :display_name,
      :username,
      :profile_type,
      :note,
      :ens_domain,
      :legal_first_name,
      :legal_last_name
    )
  end

  def tag_params
    params.permit(tags: [])
  end

  def career_need_params
    params.permit(career_needs: [])
  end

  def talent_params
    params.require(:talent).permit(
      :username,
      :display_name,
      :public,
      :disable_messages,
      :open_to_job_offers,
      :verified,
      :with_persona_id,
      profile: [
        :pronouns,
        :occupation,
        :location,
        :headline,
        :website,
        :video,
        :wallet_address,
        :email,
        :linkedin,
        :twitter,
        :telegram,
        :discord,
        :github,
        :gender,
        :ethnicity,
        :nationality,
        :based_in,
        highlighted_headline_words_index: []
      ],
      profile_picture_data: {},
      banner_data: {}
    )
  end

  def per_page
    (params[:per_page] || PER_PAGE).to_i
  end
end
