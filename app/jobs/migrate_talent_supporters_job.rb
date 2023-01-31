class MigrateTalentSupportersJob < ApplicationJob
  queue_as :default

  def perform(old_chain_id, old_contract_id, token_id)
    Talents::MigrateSupporters.new(old_chain_id: old_chain_id, old_contract_id: old_contract_id, talent_token_id: token_id).call
  end
end
