class AddRewardToInviterJob < ApplicationJob
  queue_as :default

  def perform(talent_token_id)
    talent_token = TalentToken.find(talent_token_id)

    if talent_token.contract_id.present?
      invite = Invite.find_by(id: talent_token.talent.user.invite_id)
      return unless invite

      user = invite.user

      return if user.admin?

      invite.max_uses = invite.uses + 1
      invite.save!
    end
  end
end
