class AddFirstAndLastNameToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :legal_first_name, :string
    add_column :users, :legal_last_name, :string
  end
end
