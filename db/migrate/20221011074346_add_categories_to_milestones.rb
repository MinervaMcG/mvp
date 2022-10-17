class AddCategoriesToMilestones < ActiveRecord::Migration[6.1]
  def change
    add_column :milestones, :category, :string
  end
end
