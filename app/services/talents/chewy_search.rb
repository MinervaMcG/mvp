require "web3_api/api_proxy"
module Talents
  class ChewySearch
    def initialize(filter_params: {}, admin: false)
      @filter_params = filter_params
      @admin = admin
    end

    def call
      data = TalentsIndex.class_eval(query_for_status).query(query_for_keyword).query.not({match: {profile_type: "applying"}}).order(sort_query).to_a
      data.map { |obj| obj.attributes.deep_symbolize_keys }
    end

    private

    attr_reader :filter_params, :admin

    def query_for_keyword
      {
        query_string: {
          query: "*#{keyword}*",
          fields: ["*"],
          allow_leading_wildcard: true
        }
      }
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
      elsif filter_params[:status] == "Pending approval" && admin
        'query({match: {"user.profile_type": "waiting_for_approval"}})'
      elsif filter_params[:status] == "Verified"
        "query({term: {verified: true}})"
      elsif filter_params[:status] == "By Celo Network"
        'query({match: {"talent_token.chain_id": chain_id("celo")}})'
      elsif filter_params[:status] == "By Polygon Network"
        'query({match: {"talent_token.chain_id": chain_id("polygon")}})'
      else
        "query({match_all: {}})"
      end
    end

    def sort_query
      if filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        {"talent_token.deployed_at": {order: :asc}}
      end
    end

    def keyword
      @keyword ||= filter_params[:keyword]
    end

    def chain_id(network_name)
      contract_env = ENV["CONTRACTS_ENV"]
      network = contract_env == "production" ? Web3Api::ApiProxy.const_get("#{network_name.upcase}_CHAIN") : Web3Api::ApiProxy.const_get("TESTNET_#{network_name.upcase}_CHAIN")
      network[2].to_i
    end
  end
end
