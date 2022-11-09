class AddCreatedByToRewards < ActiveRecord::Migration[6.1]
  def change
    add_reference :rewards, :creator, foreign_key: {to_table: :users}
    add_column :rewards, :imported, :boolean, default: false
    add_column :rewards, :identifier, :string
    add_index :rewards, :identifier, unique: true
  end
end
