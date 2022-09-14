class TalentTokenBlueprint < Blueprinter::Base
  fields :id, :contract_id, :ticker, :deployed_at, :chain_id

  view :normal do
    fields :deployed
  end
end
