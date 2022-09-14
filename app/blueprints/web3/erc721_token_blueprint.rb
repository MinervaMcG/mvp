class Web3::Erc721TokenBlueprint < Blueprinter::Base
  fields :id, :address

  view :normal do
    fields :name, :symbol, :url, :token_id, :amount, :show, :chain_id
  end
end
