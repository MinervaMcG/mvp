module Talents
  class ChewySearch
    def call(query_string)
      data = TalentsIndex.query(query_string: {query: "*#{query_string}*", fields: ["*"],
                                               allow_leading_wildcard: true}).to_a
      data.map { |obj| obj.attributes.deep_symbolize_keys }
    end
  end
end
