class CreateErc20Tokens < ActiveRecord::Migration[6.1]
  def change
    create_table :erc20_tokens do |t|
      t.string :address, null: false
      t.string :name
      t.string :symbol
      t.string :logo
      t.string :thumbnail
      t.integer :decimals
      t.string :balance
      t.integer :chain_id, null: false
      t.boolean :show, default: false

      t.references :user, null: false, foreign_key: true, index: true

      t.datetime :last_sync_at

      t.timestamps
    end
  end
end
