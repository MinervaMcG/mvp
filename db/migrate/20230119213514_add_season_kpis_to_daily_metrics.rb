class AddSeasonKpisToDailyMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :daily_metrics, :total_polygon_token_transactions, :integer
    add_column :daily_metrics, :total_celo_token_transactions, :integer
    add_column :daily_metrics, :total_mates_nfts, :integer
    add_column :daily_metrics, :total_onboarded_users, :integer
  end
end
