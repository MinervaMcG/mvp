class AddIsOrganisationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_organization, :boolean, default: false
  end
end
