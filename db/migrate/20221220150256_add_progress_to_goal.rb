class AddProgressToGoal < ActiveRecord::Migration[7.0]
  def change
    add_column :goals, :progress, :string
  end
end
