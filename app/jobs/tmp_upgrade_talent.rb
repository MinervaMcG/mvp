class TmpUpgradeTalent < ApplicationJob
  queue_as :low

  def perform(user_id:)
    user = User.find(user_id)

    Supporter::UpgradeToTalent.new.call(user: user, applying: true, sync_mailerlite: false)
  end
end
