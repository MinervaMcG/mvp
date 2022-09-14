class TriggerTalentSupportersRefreshJob < ApplicationJob
  queue_as :default

  def perform(*args)
    TalentToken.where(deployed: true).find_each do |talent_token|
      TalentSupportersRefreshJob.perform_later(talent_token.contract_id)
    end
  end
end
