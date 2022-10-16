class AddFirstTimeBoughtAtToTalentSupporters < ActiveRecord::Migration[6.1]
  def change
    add_column :talent_supporters, :first_time_bought_at, :datetime
  end
end
