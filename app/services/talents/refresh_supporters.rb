require "the_graph/celo/client"
require "the_graph/mumbai/client"
require "the_graph/alfajores/client"
require "the_graph/polygon/client"

module Talents
  class RefreshSupporters
    def initialize(talent_token:)
      @talent_token = talent_token
    end

    def call
      fetched_supporters_count = 0

      talent_supporters_response = talent_supporters(offset: fetched_supporters_count)
      supporters_count = talent_supporters_response.talent_token.supporter_counter.to_i
      total_supply = talent_supporters_response.talent_token.total_supply
      market_cap = talent_supporters_response.talent_token.market_cap
      token_day_data = talent_supporters_response.talent_token.token_day_data

      upsert_talent_info(supporters_count, total_supply, market_cap, token_day_data)

      loop do
        supporters = talent_supporters_response.talent_token.supporters

        upsert_talent_supporters(supporters)

        fetched_supporters_count += supporters.count

        break if fetched_supporters_count >= talent_supporters_response.talent_token.supporter_counter.to_i

        talent_supporters_response = talent_supporters(offset: fetched_supporters_count)
      end
    end

    private

    attr_reader :talent_token

    def talent_supporters(offset: 0)
      the_graph_client(talent_token.chain_id).talent_supporters(
        talent_address: talent_token.contract_id,
        offset: offset,
        variance_start_date: variance_start_date
      )
    end

    def variance_start_date
      @variance_start_date ||= (Time.now.utc - 30.days).to_i
    end

    def upsert_talent_info(supporters_count, total_supply, market_cap, token_day_data)
      talent.update!(
        supporters_count: supporters_count,
        total_supply: total_supply,
        market_cap: market_cap,
        market_cap_variance: market_cap_variance(total_supply, token_day_data)
      )
    end

    def market_cap_variance(total_supply, token_day_data)
      return 0 if token_day_data.blank?

      last_supply = token_day_data[0].daily_supply

      ((total_supply.to_f - last_supply.to_f) / last_supply.to_f).round(2)
    end

    def talent
      @talent ||= talent_token.talent
    end

    def user
      @user ||= talent.user
    end

    def upsert_talent_supporters(supporters)
      supporters.each do |supporter|
        talent_supporter = TalentSupporter.find_or_initialize_by(
          talent_contract_id: talent_token.contract_id,
          supporter_wallet_id: supporter.supporter.id
        )

        talent_supporter.update!(
          amount: supporter.amount,
          tal_amount: supporter.tal_amount,
          last_time_bought_at: Time.at(supporter.last_time_bought_at.to_i),
          first_time_bought_at: Time.at(supporter.first_time_bought_at.to_i),
          synced_at: Time.zone.now
        )

        user_supporter = User.find_by(wallet_id: supporter.supporter.id)
        upsert_connections(user_supporter) if user_supporter && user.id != user_supporter.id
      end
    end

    def upsert_connections(supporter)
      supporting_connection ||= Connection.find_or_initialize_by(
        user: user,
        connected_user: supporter
      )
      supporter_connection ||= Connection.find_or_initialize_by(
        user: supporter,
        connected_user: user
      )

      supporting_connection.refresh_connection!
      supporter_connection.refresh_connection!
    end

    def the_graph_client(chain_id)
      @the_graph_client ||=
        "TheGraph::#{TheGraphAPI::CHAIN_TO_NAME[chain_id]}::Client".constantize.new
    end
  end
end
