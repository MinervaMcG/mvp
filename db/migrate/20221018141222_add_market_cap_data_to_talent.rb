class AddMarketCapDataToTalent < ActiveRecord::Migration[6.1]
  def change
    add_column :talent, :market_cap, :string, default: "0"
    add_column :talent, :market_cap_variance, :decimal, precision: 10, scale: 2, default: 0
  end
end
