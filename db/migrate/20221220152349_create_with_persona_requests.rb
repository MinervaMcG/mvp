class CreateWithPersonaRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :with_persona_requests do |t|
      t.integer :requests_counter, null: false, default: 0
      t.integer :month, null: false
      t.integer :year, null: false

      t.timestamps
    end
  end
end
