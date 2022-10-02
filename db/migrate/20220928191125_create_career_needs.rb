class CreateCareerNeeds < ActiveRecord::Migration[6.1]
  def change
    create_table :career_needs do |t|
      t.string :title, null: false
      t.references :career_goal, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
