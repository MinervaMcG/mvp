require "web3_api/api_proxy"

module Talents
  class Search
    ADMIN_FILTER_STATUS = [
      "Admin all",
      "Pending approval"
    ].freeze

    def initialize(filter_params: {}, sort_params: {}, discovery_row: nil, admin_or_moderator: false, searching_user: nil)
      @filter_params = filter_params
      @sort_params = sort_params
      @discovery_row = discovery_row
      @admin_or_moderator = admin_or_moderator
      @searching_user = searching_user
    end

    def call
      talents = talent_scope.joins(:user, :talent_token)

      talents = talents.where.not(user: {profile_type: "applying"})
      talents = filter_by_watchlist(talents) if watchlist_only == "true"
      talents = filter_by_discovery_row(talents) if discovery_row
      talents = filter_by_keyword(talents) if keyword
      talents = filter_by_status(talents)

      sort(talents)
    end

    private

    attr_reader :discovery_row, :filter_params, :sort_params, :admin_or_moderator, :searching_user

    def talent_scope
      if admin_or_moderator && ADMIN_FILTER_STATUS.include?(filter_params[:status])
        Talent.all
      else
        Talent.base.profile_complete.where.not(user: {profile_type: "waiting_for_approval"})
      end
    end

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

    def filter_by_watchlist(talents)
      talents.where(user_id: searching_user.following.pluck(:user_id))
    end

    def keyword
      @keyword ||= filter_params[:keyword]
    end

    def watchlist_only
      @watchlist_only ||= filter_params[:watchlist_only]
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
      elsif filter_params[:status] == "Looking for a mentor"
        talents
          .joins(career_goal: :career_needs)
          .where(career_needs: {title: CareerNeed::LOOKING_MENTORSHIP})
      elsif filter_params[:status] == "Looking to mentor others"
        talents
          .joins(career_goal: :career_needs)
          .where(career_needs: {title: CareerNeed::MENTORING_OTHERS})
      elsif filter_params[:status] == "Looking to hire"
        talents
          .joins(career_goal: :career_needs)
          .where(career_needs: {title: CareerNeed::HIRING_NEEDS})
      elsif filter_params[:status] == "Looking for new opportunities"
        talents
          .joins(career_goal: :career_needs)
          .where(career_needs: {title: CareerNeed::ROLE_NEEDS})
      else
        # We're doing it this way to avoid duplicates
        random_talents = talents.select("setseed(0.#{Date.today.jd}), talent.id").order("random()")
        Talent.distinct.where(id: random_talents.pluck(:id))
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
      network = (contract_env == "production") ? Web3Api::ApiProxy.const_get("#{network_name.upcase}_CHAIN") : Web3Api::ApiProxy.const_get("TESTNET_#{network_name.upcase}_CHAIN")
      network[2].to_i
    end
  end
end
