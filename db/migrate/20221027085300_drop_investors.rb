class DropInvestors < ActiveRecord::Migration[6.1]
  def change
    drop_table :investors
  end
end
