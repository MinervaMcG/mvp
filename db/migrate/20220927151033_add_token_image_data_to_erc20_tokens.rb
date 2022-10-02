class AddTokenImageDataToErc20Tokens < ActiveRecord::Migration[6.1]
  def change
    add_column :erc20_tokens, :token_image_data, :text
  end
end
