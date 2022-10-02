class AddTokenImageDataToErc721Tokens < ActiveRecord::Migration[6.1]
  def change
    add_column :erc721_tokens, :token_image_data, :text
  end
end
