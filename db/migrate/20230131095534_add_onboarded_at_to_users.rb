class AddOnboardedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :onboarded_at, :datetime
    remove_column :users, :onboarding_complete, :boolean
  end
end
