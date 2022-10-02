class AddDescriptionToErc721Tokens < ActiveRecord::Migration[6.1]
  def change
    add_column :erc721_tokens, :description, :text
  end
end
