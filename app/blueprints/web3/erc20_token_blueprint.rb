class Web3::Erc20TokenBlueprint < Blueprinter::Base
  fields :id, :address

  view :normal do
    fields :name, :symbol, :logo, :thumbnail, :decimals, :balance, :chain_id, :show
  end
end
