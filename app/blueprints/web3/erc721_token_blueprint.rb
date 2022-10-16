class Web3::Erc721TokenBlueprint < Blueprinter::Base
  fields :id, :address

  view :normal do
    fields :symbol, :url, :token_id, :amount, :show, :chain_id

    field :local_image_url do |token, _options|
      token.token_image
    end

    field :name do |token, _options|
      token.token_name
    end

    field :description do |token, _options|
      token.token_description
    end
  end
end
