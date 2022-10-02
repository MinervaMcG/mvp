class Web3::Erc721TokenBlueprint < Blueprinter::Base
  fields :id, :address

  view :normal do
    fields :name, :symbol, :description, :url, :token_id, :amount, :show, :chain_id

    field :blockchain_image_url do |token, _options|
      token.metadata.present? ? token.metadata["image"] : nil
    end

    field :local_image_url do |token, _options|
      token.token_image_url
    end
  end
end
