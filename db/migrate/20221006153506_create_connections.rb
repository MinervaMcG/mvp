class CreateConnections < ActiveRecord::Migration[6.1]
  def change
    create_table :connections do |t|
      t.string :user_invested_amount
      t.string :connected_user_invested_amount
      t.integer :connection_type, null: false
      t.datetime :connected_at, null: false

      t.timestamps
    end

    add_reference :connections, :user, foreign_key: true
    add_reference :connections, :connected_user, foreign_key: {to_table: :users}
    add_check_constraint :connections, "user_id <> connected_user_id", name: "user_connections_constraint"

    add_index :connections, [:user_id, :connected_user_id], unique: true
  end
end
