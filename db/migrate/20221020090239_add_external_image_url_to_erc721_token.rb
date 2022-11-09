class AddExternalImageUrlToErc721Token < ActiveRecord::Migration[6.1]
  def change
    add_column :erc721_tokens, :external_image_url, :string
    remove_column :erc721_tokens, :token_image_data, :text
  end
end
