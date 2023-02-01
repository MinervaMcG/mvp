require "rails_helper"

RSpec.describe DailyMetricsJob, type: :job do
  let!(:user_1) { create :user, last_access_at: 5.days.ago, created_at: 5.days.ago }
  let!(:talent) { create :talent, user: user_1, updated_at: Date.today }
  let!(:talent_token) { create :talent_token, talent: talent, deployed: true }
  let!(:user_2) { create :user, last_access_at: Date.yesterday, talent: talent_2 }
  let!(:talent_2) { create :talent, updated_at: Date.yesterday }

  let!(:user_3) { create :user }
  let!(:message) { create :message, sender: user_3, receiver: user_1, created_at: 10.days.ago }

  let!(:user_4) { create :user, onboarded_at: nil }
  let!(:follow) { create :follow, follower: user_4, user: user_1, created_at: 26.days.ago }

  let!(:user_5) { create :user }
  let!(:talent_supporter) { create :talent_supporter, supporter_wallet_id: user_5.wallet_id, talent_contract_id: talent_token.contract_id, last_time_bought_at: 15.days.ago }

  let!(:user_6) { create :user }

  let(:web3_proxy_class) { Web3Api::ApiProxy }
  let(:web3_proxy) { instance_double(web3_proxy_class) }

  let(:upload_metrics_class) { GoogleDrive::UploadMetrics }
  let(:upload_metrics) { instance_double(upload_metrics_class, call: true) }

  let(:date) { Date.yesterday }

  let(:simple_analytics_request) { "https://simpleanalytics.com/beta.talentprotocol.com.json?end=#{date.end_of_day}&fields=seconds_on_page,visitors,pages&info=false&start=#{date.beginning_of_day}&version=5" }
  let(:simple_analytics_body) do
    {
      seconds_on_page: 20,
      visitors: 200
    }
  end

  let(:twitter_request) { "https://api.twitter.com/2/users/1383059435111780352?user.fields=public_metrics" }
  let(:twitter_body) do
    {
      data: {
        public_metrics: {
          followers_count: 10000
        }
      }
    }
  end

  let(:discord_request) { "https://discord.com/api/v9/invites/talentprotocol?with_counts=true&with_expiration=true" }
  let(:discord_body) do
    {
      approximate_member_count: 6000
    }
  end

  let(:eth_client_class) { Eth::Client }
  let(:provider) { instance_double(eth_client_class) }
  let(:eth_contract_class) { Eth::Contract }
  let(:eth_contract) { instance_double(eth_contract_class) }

  before do
    allow(web3_proxy_class).to receive(:new).and_return(web3_proxy)
    allow(upload_metrics_class).to receive(:new).and_return(upload_metrics)
    allow(web3_proxy).to receive(:retrieve_transactions_count).and_return(10)
    allow(web3_proxy).to receive(:retrieve_polygon_nfts_count).and_return(400)
    stub_request(:get, simple_analytics_request).to_return(body: simple_analytics_body.to_json)
    stub_request(:get, twitter_request).to_return(body: twitter_body.to_json)
    stub_request(:get, discord_request).to_return(body: discord_body.to_json)
    allow(eth_client_class).to receive(:create).and_return(provider)
    allow(provider).to receive(:call).and_return(60000000000000000000000)
    allow(eth_contract_class).to receive(:from_abi).and_return(eth_contract)
  end

  subject(:daily_metrics_refresh) { described_class.perform_now }

  it "creates a new daily record" do
    expect { daily_metrics_refresh }.to change(DailyMetric, :count).from(0).to(1)
  end

  it "creates a new daily record with the correct arguments" do
    daily_metrics_refresh

    created_daily_metric = DailyMetric.last

    aggregate_failures do
      expect(created_daily_metric.total_users).to eq 6
      expect(created_daily_metric.date).to eq date
      expect(created_daily_metric.total_engaged_users).to eq 5
      expect(created_daily_metric.total_active_users).to eq 1
      expect(created_daily_metric.total_onboarded_users).to eq 5
      expect(created_daily_metric.total_celo_token_transactions).to eq 20
      expect(created_daily_metric.total_polygon_token_transactions).to eq 20
      expect(created_daily_metric.total_mates_nfts).to eq 400
      expect(created_daily_metric.total_polygon_tvl).to eq 1200
      expect(created_daily_metric.total_celo_tvl).to eq 1200
      expect(created_daily_metric.time_on_page).to eq 20
      expect(created_daily_metric.visitors).to eq 200
      expect(created_daily_metric.total_twitter_followers).to eq 10000
      expect(created_daily_metric.total_discord_members).to eq 6000
    end
  end

  it "makes a request to retrieve symple analytics metrics" do
    daily_metrics_refresh

    expect(
      a_request(:get, simple_analytics_request)
    )
      .to have_been_made
      .once
  end

  it "initializes two eth providers" do
    daily_metrics_refresh

    expect(eth_client_class).to have_received(:create).twice
  end

  it "calls both staking contracts" do
    daily_metrics_refresh

    expect(provider).to have_received(:call).with(
      eth_contract,
      "totalTokensStaked"
    ).twice
  end

  it "initializes and calls the upload metrics service" do
    daily_metrics_refresh

    expect(upload_metrics_class).to have_received(:new).with(
      DailyMetric.last
    )
    expect(upload_metrics).to have_received(:call)
  end
end
