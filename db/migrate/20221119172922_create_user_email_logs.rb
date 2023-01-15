class CreateUserEmailLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :user_email_logs do |t|
      t.jsonb :sent_at_data, default: {}
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end

    remove_index :user_email_logs, :user_id
    add_index :user_email_logs, :user_id, unique: true
  end
end
