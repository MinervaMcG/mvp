class CreateGoalImages < ActiveRecord::Migration[6.1]
  def change
    create_table :goal_images do |t|
      t.references :goal, foreign_key: true, null: false, index: true
      t.text :image_data

      t.timestamps
    end

    add_column :goals, :link, :string
  end
end
