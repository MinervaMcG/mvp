class CreateErc721Tokens < ActiveRecord::Migration[6.1]
  def change
    create_table :erc721_tokens do |t|
      t.string :address, null: false
      t.string :name
      t.string :symbol
      t.string :url
      t.json :metadata
      t.string :token_id
      t.string :amount
      t.integer :chain_id, null: false
      t.boolean :show, default: false

      t.string :nft_type, null: false

      t.references :user, null: false, foreign_key: true, index: true

      t.datetime :last_sync_at

      t.timestamps
    end
  end
end
