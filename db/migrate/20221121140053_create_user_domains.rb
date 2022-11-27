class CreateUserDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :user_domains do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain, null: false
      t.integer :chain_id, null: false
      t.string :wallet, null: false
      t.string :provider, null: false

      t.timestamps
    end

    add_index :user_domains, [:user_id, :domain, :chain_id, :wallet], unique: true, name: "unique_user_domain_fields_index"
  end
end
