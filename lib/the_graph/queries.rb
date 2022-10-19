module TheGraph
  module Queries
    TALENT_SUPPORTERS_QUERY = <<-'GRAPHQL'
      query($id: ID!, $skip: Int!, $first: Int!, $variance_start_date: Int!) {
        talentToken(id: $id) {
          supporterCounter
          totalSupply
          marketCap
          tokenDayData(
            where: { date_lte: $variance_start_date }
            orderBy: date
            orderDirection: desc
            first: 1
          ) {
            id
            date
            dailySupply
          }
          supporters(
            skip: $skip
            first: $first
            orderBy: id
            orderDirection: asc
          ) {
            id
            amount
            lastTimeBoughtAt
            firstTimeBoughtAt
            supporter {
              id
            }
            talAmount
          }
        }
      }
    GRAPHQL
  end
end
