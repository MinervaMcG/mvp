class MigrateTalentSupportersJob < ApplicationJob
  queue_as :default

  def perform(old_chain_id, old_contract_id, token_id)
    Talents::MigrateSupporters.new(old_chain_id: chain_id_was, old_contract_id: contract_id_was, talent_token_id: id).call
  end
end
