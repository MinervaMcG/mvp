require "graphql/client"
require "graphql/client/http"

# The Graph API wrapper
module TheGraphAPI
  CHAIN_TO_NAME = {
    137 => "Polygon",
    44787 => "Alfajores",
    42220 => "Celo",
    80001 => "Mumbai"
  }

  module Celo
    HTTP = GraphQL::Client::HTTP.new("https://api.thegraph.com/subgraphs/name/talent-protocol/prod") do
      def headers(context)
        {"User-Agent": "Talent Protocol"}
      end
    end

    Schema = GraphQL::Client.load_schema(HTTP)

    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end

  module Alfajores
    HTTP = GraphQL::Client::HTTP.new("https://api.thegraph.com/subgraphs/name/talent-protocol/dev") do
      def headers(context)
        {"User-Agent": "Talent Protocol"}
      end
    end

    Schema = GraphQL::Client.load_schema(HTTP)

    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end

  module Mumbai
    HTTP = GraphQL::Client::HTTP.new("https://api.thegraph.com/subgraphs/name/talent-protocol/mumbai-dev") do
      def headers(context)
        {"User-Agent": "Talent Protocol"}
      end
    end

    Schema = GraphQL::Client.load_schema(HTTP)

    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end

  module Polygon
    HTTP = GraphQL::Client::HTTP.new("https://api.thegraph.com/subgraphs/name/talent-protocol/polygon-prod") do
      def headers(context)
        {"User-Agent": "Talent Protocol"}
      end
    end

    Schema = GraphQL::Client.load_schema(HTTP)

    Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  end
end
