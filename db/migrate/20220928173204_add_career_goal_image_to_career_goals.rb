class AddCareerGoalImageToCareerGoals < ActiveRecord::Migration[6.1]
  def change
    add_column :career_goals, :image_data, :text
  end
end
