module Talents
  class ChewySearch
    def initialize(filter_params: {})
      @filter_params = filter_params
    end

    def call
      data = TalentsIndex.query(query_for_keyword).query(query_for_status).order({"talent_token.deployed_at": {order: :asc}}).to_a
      data.map { |obj| obj.attributes.deep_symbolize_keys }
    end

    private

    attr_reader :filter_params

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
        {
          exists: {
            field: "talent_token.contract_id"
          }
        }
      elsif filter_params[:status] == "Latest added" || filter_params[:status] == "Trending"
        [{
          exists: {
            field: "talent_token.contract_id"
          }
        }, {
          range: {
            "talent_token.deployed_at": {
              gte: 1.month.ago
            }
          }
        }]
      end
    end

    def keyword
      @keyword ||= filter_params[:keyword]
    end
  end
end
