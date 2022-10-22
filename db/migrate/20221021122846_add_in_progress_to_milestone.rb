class AddInProgressToMilestone < ActiveRecord::Migration[6.1]
  def change
    add_column :milestones, :in_progress, :boolean, default: false
  end
end
