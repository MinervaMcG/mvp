class API::UpdateTalent
  attr_reader :talent, :user, :success

  def initialize(talent, user)
    @talent = talent
    @user = user
    @success = false
  end

  def call(talent_params, user_params, tag_params, career_need_params)
    update_talent(talent_params)
    update_user(user_params)
    update_tags(tag_params[:tags]) if tag_params[:tags]
    update_career_needs(career_need_params[:career_needs]) if career_need_params[:career_needs]

    @success = true
  end

  private

  def talent_user
    @talent_user ||= talent.user
  end

  def update_user(params)
    if params[:profile_type]
      Users::UpdateProfileType.new.call(
        user: talent_user,
        who_dunnit_id: user.id,
        new_profile_type: params[:profile_type],
        note: params[:note]
      )

      if params[:profile_type] == "waiting_for_approval"
        Tasks::Update.new.call(type: "Tasks::ApplyTokenLaunch", user: talent_user)
      end

      if params[:profile_type] == "approved"
        talent.update!(public: true)
      end
    end

    talent_user.update!(params.except(:profile_type, :note))
  end

  def update_talent(params)
    if talent[:public] != params[:public] && params.key?(:public)
      # Notify mailerlite that profile was set public
      talent[:public] = params[:public] || false

      AddUsersToMailerliteJob.perform_later(talent_user.id)
    end

    if params.key?(:profile_picture_data)
      talent.profile_picture = params[:profile_picture_data].as_json
      talent.profile_picture_derivatives! if talent.profile_picture && talent.profile_picture_changed?
    end

    if params[:profile]
      if params[:profile][:headline]
        talent[:disable_messages] = params[:disable_messages] || false
        talent.pronouns = params[:profile][:pronouns]
        talent.occupation = params[:profile][:occupation]
        talent.location = params[:profile][:location]
        talent.headline = params[:profile][:headline]
        talent.website = params[:profile][:website]
        talent.video = params[:profile][:video]
        talent.wallet_address = params[:profile][:wallet_address]
        talent.gender = params[:profile][:gender]
        talent.nationality = params[:profile][:nationality]
        talent.ethnicity = params[:profile][:ethnicity]
        talent.based_in = params[:profile][:based_in]
        talent.highlighted_headline_words_index = params[:profile][:highlighted_headline_words_index]

        if params[:profile][:occupation]
          UpdateTasksJob.perform_later(type: "Tasks::FillInAbout", user_id: talent_user.id)
        end
      end

      if params[:profile][:discord]
        talent.discord = params[:profile][:discord]
      end
      if params[:profile][:linkedin]
        talent.linkedin = params[:profile][:linkedin]
      end

      if params[:profile][:telegram]
        talent.telegram = params[:profile][:telegram]
      end

      if params[:profile][:github]
        talent.github = params[:profile][:github]
      end

      if params[:profile][:twitter]
        talent.twitter = params[:profile][:twitter]
      end
    end

    if params.key?(:open_to_job_offers)
      talent.open_to_job_offers = params[:open_to_job_offers]
    end

    if params.key?(:verified)
      talent.verified = params[:verified]
      Tasks::Update.new.call(type: "Tasks::Verified", user: talent_user) if talent.verified?
    end

    if params.key?(:banner_data)
      talent.banner = params[:banner_data].as_json
      talent.banner_derivatives! if talent.banner && talent.banner_changed?
    end

    talent.save!
  end

  def update_tags(all_tags)
    talent
      .user
      .user_tags
      .joins(:tag)
      .where(tag: {hidden: false})
      .where.not(tag: {description: all_tags})
      .delete_all

    all_tags.each do |description|
      tag = Tag.find_or_create_by(description: description.downcase)
      user_tag = UserTag.find_or_initialize_by(user: talent_user, tag: tag)

      user_tag.save! unless user_tag.persisted?
    end
  end

  def update_career_needs(career_needs)
    CareerNeeds::Upsert.new(career_goal: talent.career_goal, titles: career_needs).call
  end
end
