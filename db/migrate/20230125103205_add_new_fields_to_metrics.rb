class AddNewFieldsToMetrics < ActiveRecord::Migration[7.0]
  def change
    add_column :daily_metrics, :total_talent_token_applications, :integer
    add_column :daily_metrics, :total_approved_talent_token_applications, :integer
    add_column :daily_metrics, :time_on_page, :integer
    add_column :daily_metrics, :visitors, :integer
    add_column :daily_metrics, :total_polygon_tvl, :integer
    add_column :daily_metrics, :total_celo_tvl, :integer
    add_column :daily_metrics, :total_twitter_followers, :integer
    add_column :daily_metrics, :total_discord_members, :integer
    remove_column :daily_metrics, :talent_applications
  end
end
