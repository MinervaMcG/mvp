class AddExperienceLevelToTalent < ActiveRecord::Migration[6.1]
  def change
    add_column :talent, :experience_level, :integer, default: 0
  end
end
