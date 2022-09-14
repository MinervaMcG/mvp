class TalentSupportersRefreshJob < ApplicationJob
  queue_as :default

  def perform(talent_contract_id)
    talent_token = TalentToken.where(deployed: true).find_by!(contract_id: talent_contract_id)
    Talents::RefreshSupporters.new(talent_token: talent_token).call
  end
end
