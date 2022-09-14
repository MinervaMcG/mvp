module Users
  class UpdateProfileType
    def call(user:, new_profile_type:, who_dunnit_id: nil, note: nil)
      previous_profile_type = user.profile_type

      return if previous_profile_type == new_profile_type || previous_profile_type === "talent"

      user.update!(profile_type: new_profile_type)

      if new_profile_type == "approved"
        CreateNotification.new.call(
          recipient: user,
          type: TalentApplicationApprovedNotification,
          source_id: who_dunnit_id
        )
      elsif new_profile_type == "rejected"
        CreateNotification.new.call(
          recipient: user,
          type: TalentApplicationRejectedNotification,
          source_id: who_dunnit_id,
          extra_params: {
            note: note
          }
        )
      end

      UserProfileTypeChange.create!(
        user_id: user.id,
        who_dunnit_id: who_dunnit_id || user.id,
        previous_profile_type: previous_profile_type,
        new_profile_type: new_profile_type,
        note: note
      )
    rescue => e
      Rollbar.error(
        e,
        user_id: user.id,
        who_dunnit_id: who_dunnit_id || user.id,
        previous_profile_type: previous_profile_type,
        new_profile_type: new_profile_type,
        note: note
      )
    end
  end
end
