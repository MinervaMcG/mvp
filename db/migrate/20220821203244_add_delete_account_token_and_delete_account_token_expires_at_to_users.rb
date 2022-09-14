class AddDeleteAccountTokenAndDeleteAccountTokenExpiresAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :delete_account_token, :string
    add_column :users, :delete_account_token_expires_at, :datetime
  end
end
