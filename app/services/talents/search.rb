require "web3_api/api_proxy"

module Talents
  class Search
    def initialize(filter_params: {}, sort_params: {}, discovery_row: nil, admin_or_moderator: false)
      @filter_params = filter_params
      @sort_params = sort_params
      @discovery_row = discovery_row
      @admin_or_moderator = admin_or_moderator
    end

    def call
      talents = admin_or_moderator ? Talent.joins(:user, :talent_token) : Talent.base.joins(:user, :talent_token)

      talents = talents.where.not(user: {profile_type: "applying"})
      talents = filter_by_discovery_row(talents) if discovery_row
      talents = filter_by_keyword(talents) if keyword
      talents = filter_by_status(talents)

      sort(talents)
    end

    private

    attr_reader :discovery_row, :filter_params, :sort_params, :admin_or_moderator

    def filter_by_discovery_row(talents)
      users = User.joins(tags: :discovery_row)
      users = users.where("discovery_rows.id = ? AND users.profile_type = ?", discovery_row.id, "talent")

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
      if filter_params[:status] == "Launching soon"
        talents.upcoming.order(created_at: :asc)
      elsif filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        talents
          .active
          .where("talent_tokens.deployed_at > ?", 1.month.ago)
          .order("talent_tokens.deployed_at ASC")
      elsif filter_params[:status] == "Pending approval" && admin_or_moderator
        talents.where(user: {profile_type: "waiting_for_approval"})
      elsif filter_params[:status] == "Verified"
        talents.where(verified: true)
      elsif filter_params[:status] == "By Celo Network"
        talents.where(talent_token: {chain_id: chain_id("celo")})
      elsif filter_params[:status] == "By Polygon Network"
        talents.where(talent_token: {chain_id: chain_id("polygon")})
      else
        talents
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

    def chain_id(network_name)
      contract_env = ENV["CONTRACTS_ENV"]
      network = contract_env == "production" ? Web3Api::ApiProxy.const_get("#{network_name.upcase}_CHAIN") : Web3Api::ApiProxy.const_get("TESTNET_#{network_name.upcase}_CHAIN")
      network[2].to_i
    end
  end
end
