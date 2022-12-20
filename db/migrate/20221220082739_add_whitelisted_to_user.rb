class AddWhitelistedToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :whitelisted_talent_mate, :boolean, default: false
  end
end
