module GoogleDrive
  class UploadMetrics
    METRICS_SHEET_ID = "1eNhm1_xyv3iZ-ipqTZ4tTsnJKBKH8BsRIalJNgiYfX4"

    def initialize(daily_metric)
      @daily_metric = daily_metric
    end

    def call
      # Add empty row before the second row
      # The second row is the last data point
      daily_data_sheet.insert_rows(2, daily_metric_row)
      daily_data_sheet.save
    end

    private

    attr_reader :daily_metric

    def daily_metric_row
      [[
        daily_metric.date.to_s,
        daily_metric.total_users,
        daily_metric.total_connected_wallets,
        daily_metric.total_engaged_users,
        daily_metric.total_active_users,
        daily_metric.total_onboarded_users,
        daily_metric.total_dead_accounts,
        daily_metric.total_talent_token_applications,
        daily_metric.total_approved_talent_token_applications,
        daily_metric.total_beginner_quests_completed,
        daily_metric.total_complete_profile_quests_completed,
        daily_metric.total_supporter_quests_completed,
        daily_metric.time_on_page,
        daily_metric.visitors,
        daily_metric.total_celo_tokens,
        daily_metric.total_polygon_tokens,
        daily_metric.total_celo_supporters,
        daily_metric.total_polygon_supporters,
        daily_metric.total_celo_token_transactions,
        daily_metric.total_polygon_token_transactions,
        daily_metric.total_mates_nfts,
        daily_metric.total_celo_token_transactions.to_i + daily_metric.total_polygon_token_transactions.to_i + daily_metric.total_mates_nfts.to_i,
        daily_metric.total_polygon_tvl,
        daily_metric.total_celo_tvl,
        daily_metric.total_celo_tvl.to_i + daily_metric.total_polygon_tvl.to_i,
        daily_metric.total_advocates,
        daily_metric.total_scouts,
        daily_metric.total_twitter_followers,
        daily_metric.total_discord_members
      ]]
    end

    def daily_data_sheet
      @daily_data_sheet ||= metrics_sheet.worksheet_by_title("Daily Data")
    end

    def metrics_sheet
      session.spreadsheet_by_key(METRICS_SHEET_ID)
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(StringIO.new(config))
    end

    def config
      ENV["GOOGLE_SERVICE_ACCOUNT_JSON"]
    end
  end
end
