require "the_graph/queries"

module TheGraph
  module Mumbai
    MAX_RECORDS = 100

    TALENT_SUPPORTERS = ::TheGraphAPI::Mumbai::Client.parse TheGraph::Queries::TALENT_SUPPORTERS_QUERY

    class Client
      class Error < StandardError; end

      class QueryError < Error; end

      def talent_supporters(talent_address:, variance_start_date:, offset: 0)
        query TALENT_SUPPORTERS, id: talent_address, variance_start_date: variance_start_date, skip: offset, first: MAX_RECORDS
      end

      private

      def query(definition, variables = {})
        response = ::TheGraphAPI::Mumbai::Client.query(definition, variables: variables)

        if response.errors.any?
          raise QueryError.new(response.errors[:data].join(", "))
        else
          response.data
        end
      end
    end
  end
end
