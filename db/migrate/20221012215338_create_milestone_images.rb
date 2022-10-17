class CreateMilestoneImages < ActiveRecord::Migration[6.1]
  def change
    create_table :milestone_images do |t|
      t.references :milestone, foreign_key: true, null: false, index: true
      t.text :image_data

      t.timestamps
    end
  end
end
