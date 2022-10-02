require "web3/api_proxy"

module Talents
  class Search
    def initialize(filter_params: {}, sort_params: {}, discovery_row: nil, admin: false)
      @filter_params = filter_params
      @sort_params = sort_params
      @discovery_row = discovery_row
      @admin = admin
    end

    def call
      talents = admin ? Talent.joins(:user, :talent_token) : Talent.base.joins(:user, :talent_token)

      talents = filter_by_discovery_row(talents) if discovery_row
      talents = filter_by_keyword(talents) if keyword
      talents = filter_by_status(talents)

      sort(talents)
    end

    private

    attr_reader :discovery_row, :filter_params, :sort_params, :admin

    def filter_by_discovery_row(talents)
      users = User.joins(tags: :discovery_row)

      users = users.where(
        "discovery_rows.id = ?",
        discovery_row.id
      )

      talents.where(user_id: users.distinct.pluck(:id))
    end

    def filter_by_keyword(talents)
      users = User.joins(talent: :talent_token).left_joins(:tags)

      users = users.where(
        "users.username ilike :keyword " \
        "OR users.display_name ilike :keyword " \
        "OR talent_tokens.ticker ilike :keyword " \
        "OR tags.description ilike :keyword ",
        keyword: "%#{keyword}%"
      )

      talents.where(user: users.distinct.select(:id))
    end

    def keyword
      @keyword ||= filter_params[:keyword]
    end

    def filter_by_status(talents)
      contract_env = ENV["CONTRACTS_ENV"]

      if filter_params[:status] == "Launching soon"
        talents.upcoming.order(created_at: :asc)
      elsif filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        talents
          .active
          .where("talent_tokens.deployed_at > ?", 1.month.ago)
          .order("talent_tokens.deployed_at ASC")
      elsif filter_params[:status] == "Pending approval" && admin
        talents.where(user: {profile_type: "waiting_for_approval"})
      elsif filter_params[:status] == "Verified"
        talents.where(verified: true)
      elsif filter_params[:status] == "By Celo Network"
        chain_id = contract_env == "production" ? Web3::ApiProxy::CELO_CHAIN[2].to_i : Web3::ApiProxy::STAGING_CELO_CHAIN[2].to_i
        talents.where(talent_token: {chain_id: chain_id})
      elsif filter_params[:status] == "By Polygon Network"
        chain_id = contract_env == "production" ? Web3::ApiProxy::POLYGON_CHAIN[2].to_i : Web3::ApiProxy::STAGING_POLYGON_CHAIN[2].to_i
        talents.where(talent_token: {chain_id: chain_id})
      else
        talents
          .select("setseed(0.#{Date.today.jd}), talent.*")
          .order("random()")
      end
    end

    def sort(talents)
      if sort_params[:sort].present?
        if sort_params[:sort] == "market_cap"
          talents.joins(:talent_token).order(market_cap: :desc)
        elsif sort_params[:sort] == "activity"
          talents.order(activity_count: :desc)
        else
          talents.order(created_at: :desc)
        end
      else
        talents.order(created_at: :desc)
      end
    end
  end
end
