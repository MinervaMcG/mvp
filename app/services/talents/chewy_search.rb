require "web3_api/api_proxy"

module Talents
  class ChewySearch
    PAGE_NEUTRALIZER = 1

    def initialize(filter_params: {}, admin_or_moderator: false, size: 40, from: 1, current_user_watchlist: [])
      @filter_params = filter_params
      @admin_or_moderator = admin_or_moderator
      @size = size
      @from = from
      @current_user_watchlist = current_user_watchlist
    end

    def call
      talents = TalentsIndex.class_eval(query_for_status).query(query_for_keyword).query.not({match: {profile_type: "applying"}})
      talents = talents.order(sort_query)
      total_count = talents.count
      talents = talents.limit(size).offset(from)
      [{
        current_page: ((from + PAGE_NEUTRALIZER) / size.to_f).ceil,
        last_page: (total_count / size.to_f).ceil
      }, talents.entries.map do |talent|
        attributes = talent.attributes.deep_stringify_keys
        attributes["is_following"] = current_user_watchlist&.include?(attributes["user_id"])
        attributes
      end]
    end

    private

    attr_reader :filter_params, :admin_or_moderator, :size, :from, :current_user_watchlist

    def query_for_keyword
      unless keyword.blank?
        {
          query_string: {
            query: "*#{keyword}*",
            fields: ["*"],
            allow_leading_wildcard: true
          }
        }
      end
    end

    def query_for_status
      if filter_params[:status] == "Launching soon"
        'query.not({exists: {field: "talent_token.contract_id"}})'
      elsif filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        'query([{
          exists: {field: "talent_token.contract_id"}
        }, {
          range: {
            "talent_token.deployed_at": {
              gte: 1.month.ago
            }
          }
        }])'
      elsif filter_params[:status] == "Pending approval" && admin_or_moderator
        'query({match: {"user.profile_type": "waiting_for_approval"}})'
      elsif filter_params[:status] == "Verified"
        "query({term: {verified: true}})"
      elsif filter_params[:status] == "By Celo Network"
        "query([{
          exists: {field: 'talent_token.contract_id'}
        }, {
          match: {'talent_token.chain_id': #{Web3Api::ApiProxy.chain_id("celo")}}
        }])"
      elsif filter_params[:status] == "By Polygon Network"
        "query([{
          exists: {field: 'talent_token.contract_id'}
        }, {
          match: {'talent_token.chain_id': #{Web3Api::ApiProxy.chain_id("polygon")}}
        }])"
      else
        "query({match_all: {}})"
      end
    end

    def sort_query
      if filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        {"talent_token.deployed_at": {order: :asc, unmapped_type: "date"}}
      end
    end

    def keyword
      @keyword ||= filter_params[:keyword]
    end
  end
end
