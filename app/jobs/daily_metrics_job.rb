require "web3_api/api_proxy"
require "google_drive/upload_metrics"

class DailyMetricsJob < ApplicationJob
  queue_as :low

  POLYGON_STAKING_ADDRESS = "0xE23104E89fF4c93A677136C4cBdFD2037B35BE67"
  CELO_STAKING_ADDRESS = "0x5a6eF881E3707AAf7201dDb7c198fc94B4b12636"

  POLYGON_CONTRACTS = [
    "0xbbfeda7c4d8d9df752542b03cdd715f790b32d0b",
    POLYGON_STAKING_ADDRESS
  ]
  POLYGON_MATES_CONTRACT = "0x41033160a2351358ddc1b97edd0bc6f00cdeca92"

  CELO_CONTRACTS = [
    "0xa902DA7a40a671B84bA3Dd0BdBA6FD9d2D888246",
    CELO_STAKING_ADDRESS
  ]

  TRANSACTIONS_KPI_START_DATE = Date.new(2023, 0o1, 0o1).to_time.to_i

  def perform
    daily_metric = DailyMetric.create!(
      date: date,
      total_users: total_users,
      total_connected_wallets: total_connected_wallets,
      total_active_users: total_active_users,
      total_dead_accounts: total_dead_accounts,
      total_advocates: total_advocates,
      total_scouts: total_scouts,
      total_beginner_quests_completed: total_beginner_quests_completed,
      total_complete_profile_quests_completed: total_complete_profile_quests_completed,
      total_supporter_quests_completed: total_supporter_quests_completed,
      total_celo_tokens: total_celo_tokens,
      total_celo_supporters: total_celo_supporters,
      total_polygon_tokens: total_polygon_tokens,
      total_polygon_supporters: total_polygon_supporters,
      total_engaged_users: total_engaged_users,
      total_onboarded_users: total_onboarded_users,
      total_polygon_token_transactions: total_polygon_token_transactions,
      total_celo_token_transactions: total_celo_token_transactions,
      total_mates_nfts: total_mates_nfts,
      total_talent_token_applications: total_talent_token_applications,
      total_approved_talent_token_applications: total_approved_talent_token_applications,
      time_on_page: time_on_page,
      visitors: visitors,
      total_polygon_tvl: total_polygon_tvl,
      total_celo_tvl: total_celo_tvl,
      total_twitter_followers: total_twitter_followers,
      total_discord_members: total_discord_members
    )
    # Uploads the daily metric to the google sheet
    GoogleDrive::UploadMetrics.new(daily_metric).call
  end

  private

  def date
    Date.yesterday
  end

  def total_users
    User.count
  end

  def total_connected_wallets
    User.where.not(wallet_id: nil).count
  end

  def total_active_users
    User.where("users.last_access_at > ? and users.last_access_at::date != users.created_at::date", one_month_ago).count
  end

  def total_dead_accounts
    query = <<~SQL
      SELECT COUNT(*)
      FROM users
      WHERE (
          users.last_access_at > (current_date - interval '60' day)
          AND DATE(users.created_at) = DATE(users.last_access_at)
      ) OR users.last_access_at < (current_date - interval '180' day)
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def total_engaged_users
    query = <<~SQL
      SELECT COUNT(*)
      FROM users
      WHERE users.id IN (
          select talent.user_id
          from talent
          left join talent_tokens on talent.id = talent_tokens.talent_id
          left join career_goals on talent.id = career_goals.talent_id
          left join perks on talent.id = perks.talent_id
          left join milestones on talent.id = milestones.talent_id
          left join goals on career_goals.id = goals.career_goal_id
          where talent.updated_at > :one_month_ago
          OR talent_tokens.updated_at > :one_month_ago
          OR career_goals.updated_at > :one_month_ago
          OR perks.updated_at > :one_month_ago
          OR perks.created_at > :one_month_ago
          OR milestones.updated_at > :one_month_ago
          OR milestones.created_at > :one_month_ago
          OR goals.updated_at > :one_month_ago
          OR goals.created_at > :one_month_ago
      )
      OR users.wallet_id IN (
          select talent_supporters.supporter_wallet_id
          from talent_supporters
          where talent_supporters.last_time_bought_at > :one_month_ago
      )
      OR users.id IN (
          select messages.sender_id
          from messages
          where messages.created_at > :one_month_ago
      )
      OR users.id IN (
          select follows.follower_id
          from follows
          where follows.created_at > :one_month_ago
      )
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query, one_month_ago: one_month_ago])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def total_advocates
    query = <<~SQL
      SELECT COUNT(DISTINCT user_id)
      FROM invites
      where id IN (
          SELECT invite_id
          FROM users
          WHERE tokens_purchased = true
      )
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query, date: date])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def total_scouts
    query = <<~SQL
      SELECT COUNT(DISTINCT user_id)
      FROM invites
      where id IN (
          SELECT invite_id
          FROM users
          INNER JOIN talent on users.id = talent.user_id
          INNER JOIN talent_tokens on talent.id = talent_tokens.talent_id
          WHERE talent_tokens.contract_id IS NOT NULL
      )
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query, date: date])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def total_beginner_quests_completed
    Quest.where(type: "Quests::User", status: "done").count
  end

  def total_complete_profile_quests_completed
    Quest.where(type: "Quests::TalentProfile", status: "done").count
  end

  def total_supporter_quests_completed
    Quest.where(type: "Quests::Supporter", status: "done").count
  end

  def total_celo_tokens
    TalentToken.where(chain_id: 42220, deployed: true).count
  end

  def total_celo_supporters
    celo_contracts = TalentToken.where(chain_id: 42220, deployed: true).pluck(:contract_id)
    TalentSupporter.where(talent_contract_id: celo_contracts).distinct.count(:supporter_wallet_id)
  end

  def total_polygon_tokens
    TalentToken.where(chain_id: 137, deployed: true).count
  end

  def total_polygon_supporters
    polygon_contracts = TalentToken.where(chain_id: 137, deployed: true).pluck(:contract_id)
    TalentSupporter.where(talent_contract_id: polygon_contracts).distinct.count(:supporter_wallet_id)
  end

  def total_onboarded_users
    User.where.not(onboarded_at: nil).count
  end

  def total_polygon_token_transactions
    count = 0
    POLYGON_CONTRACTS.each do |contract_address|
      count += web3_proxy.retrieve_transactions_count(
        address: contract_address,
        chain: "polygon",
        start_timestamp: TRANSACTIONS_KPI_START_DATE
      )
    end

    count
  end

  def total_celo_token_transactions
    count = 0
    CELO_CONTRACTS.each do |contract_address|
      count += web3_proxy.retrieve_transactions_count(
        address: contract_address,
        chain: "celo",
        start_timestamp: TRANSACTIONS_KPI_START_DATE
      )
    end
    count
  end

  def total_mates_nfts
    web3_proxy.retrieve_polygon_nfts_count(
      address: POLYGON_MATES_CONTRACT
    )
  end

  def total_talent_token_applications
    query = <<~SQL
      SELECT COUNT(DISTINCT(user_id))
      FROM user_profile_type_changes
      where new_profile_type = 'waiting_for_approval'
      and created_at::date <= :date
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query, date: date])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def total_approved_talent_token_applications
    query = <<~SQL
      SELECT COUNT(DISTINCT(user_id))
      FROM user_profile_type_changes
      where new_profile_type = 'approved'
      and created_at::date <= :date
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([query, date: date])

    ActiveRecord::Base.connection.execute(sanitized_sql).first["count"]
  end

  def time_on_page
    analytics_json["seconds_on_page"]
  end

  def visitors
    analytics_json["visitors"]
  end

  def analytics_json
    @analytics_json ||= begin
      resp = Faraday.get(
        "https://simpleanalytics.com/beta.talentprotocol.com.json",
        {
          start: date.beginning_of_day,
          end: date.end_of_day,
          info: false,
          fields: "seconds_on_page,visitors,pages",
          version: 5
        }
      )
      JSON.parse(resp.body)
    end
  end

  # TVL in USD
  def total_polygon_tvl
    (polygon_provider.call(polygon_staking_contract, "totalTokensStaked") * TalentToken::TAL_VALUE_IN_USD) / TalentToken::TAL_DECIMALS
  end

  # TVL in USD
  def total_celo_tvl
    (celo_provider.call(celo_staking_contract, "totalTokensStaked") * TalentToken::TAL_VALUE_IN_USD) / TalentToken::TAL_DECIMALS
  end

  def polygon_staking_contract
    @polygon_staking_contract ||= Eth::Contract.from_abi(name: staking_contract_abi["contractName"], address: POLYGON_STAKING_ADDRESS, abi: staking_contract_abi["abi"])
  end

  def celo_staking_contract
    @celo_staking_contract ||= Eth::Contract.from_abi(name: staking_contract_abi["contractName"], address: CELO_STAKING_ADDRESS, abi: staking_contract_abi["abi"])
  end

  def polygon_provider
    @polygon_provider ||= Eth::Client.create "https://polygon-rpc.com"
  end

  def celo_provider
    @celo_provider ||= Eth::Client.create "https://forno.celo.org"
  end

  def staking_contract_abi
    @staking_contract_abi ||= JSON.parse(File.read("lib/abi/Staking.json"))
  end

  def total_twitter_followers
    resp = Faraday.get("https://api.twitter.com/2/users/1383059435111780352?user.fields=public_metrics", {}, {Authorization: "Bearer #{ENV["TWITTER_API_TOKEN"]}"})
    body = JSON.parse(resp.body)

    body["data"]["public_metrics"]["followers_count"]
  end

  def total_discord_members
    resp = Faraday.get("https://discord.com/api/v9/invites/talentprotocol?with_counts=true&with_expiration=true", {})
    body = JSON.parse(resp.body)
    body["approximate_member_count"]
  end

  def one_month_ago
    @one_month_ago ||= 31.days.ago.beginning_of_day
  end

  def web3_proxy
    @web3_proxy ||= Web3Api::ApiProxy.new
  end
end
