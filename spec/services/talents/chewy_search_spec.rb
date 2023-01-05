require "rails_helper"

RSpec.describe Talents::ChewySearch do
  subject(:search_talents) do
    described_class.new(
      filter_params: filter_params
    ).call
  end

  subject(:search_object) do
    described_class.new(
      filter_params: filter_params,
      admin_or_moderator: admin_or_moderator
    )
  end

  let!(:user_1) { create :user, talent: talent_1, username: "jonas" }
  let(:talent_1) { create :talent, :with_token, public: true }
  let!(:user_2) { create :user, talent: talent_2, display_name: "Alexander" }
  let(:talent_2) { create :talent, :with_token, public: true }
  let!(:user_3) { create :user, talent: talent_3, username: "jonathan" }
  let(:talent_3) { create :talent, :with_token, public: true }
  let!(:user_4) { create :user, talent: talent_4, display_name: "Alex" }
  let(:talent_4) { create :talent, :with_token, public: true }
  let!(:user_5) { create :user, talent: talent_5, username: "john" }
  let(:talent_5) { create :talent, talent_token: token_5, public: true }
  let(:token_5) { create :talent_token, deployed_at: Time.now }

  let!(:user_without_launched_token) { create :user, talent: talent_without_launched_token, username: "alexa" }
  let(:talent_without_launched_token) { create :talent, talent_token: token_without_launch, public: true }
  let(:token_without_launch) { create :talent_token, contract_id: nil }

  let!(:verfied_talent_user) { create :user, talent: verified_talent, username: "verfied" }
  let(:verified_talent) { create :talent, :with_token, verified: true, public: true }

  let!(:celo_talent_user) { create :user, talent: celo_talent, username: "will" }
  let(:celo_talent) { create :talent, talent_token: celo_talent_token, public: true }
  let(:celo_talent_token) { create :talent_token, chain_id: 44787 }

  let!(:polygon_talent_user) { create :user, talent: polygon_talent, username: "ryan" }
  let(:polygon_talent) { create :talent, talent_token: polygon_talent_token, public: true }
  let(:polygon_talent_token) { create :talent_token, chain_id: 80001 }

  let!(:user_without_token) { create :user, talent: talent_without_token, username: "jona" }
  let(:talent_without_token) { create :talent, public: true }

  before do
    TalentsIndex.purge!
    TalentsIndex.import!
  end

  context "when the keyword filter is passed" do
    context "when it matches the user username" do
      let(:filter_params) do
        {
          keyword: "on"
        }
      end

      it "returns all talent users with username matching the passed keyword" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_3, talent_without_token].pluck(:id))
      end
    end

    context "when it matches the user display_name" do
      let(:filter_params) do
        {
          keyword: "lex"
        }
      end

      it "returns all talent users with display_name matching the passed keyword" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_4, talent_without_launched_token].pluck(:id))
      end
    end

    context "when it matches the user tags" do
      let(:filter_params) do
        {
          keyword: "web3"
        }
      end

      before do
        tag_1 = create :tag, description: "web3"
        tag_2 = create :tag, description: "design"
        tag_3 = create :tag, description: "development"

        user_1.tags << [tag_1, tag_3]
        user_2.tags << [tag_2]
        user_3.tags << [tag_1, tag_2]
        user_4.tags << [tag_3]

        TalentsIndex.import!
      end

      it "returns all talent users with tags matching the passed keyword" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_3].pluck(:id))
      end
    end
  end

  describe "#query_for_keyword" do
    let(:filter_params) do
      {
        keyword: "on"
      }
    end

    let(:admin_or_moderator) { false }

    it "returns the query" do
      expect(search_object.send(:query_for_keyword)).to eq({
        query_string: {
          query: "*on*",
          fields: ["*"],
          allow_leading_wildcard: true
        }
      })
    end
  end

  describe "#query_for_status" do
    let(:admin_or_moderator) { false }

    context "when the status is Launching soon" do
      let(:filter_params) do
        {
          status: "Launching soon"
        }
      end

      it "returns the query" do
        expect(search_object.send(:query_for_status)).to eq('query.not({exists: {field: "talent_token.contract_id"}})')
      end
    end

    context "when the status is Trending" do
      let(:filter_params) do
        {
          status: "Trending"
        }
      end

      it "returns the query" do
        expect(search_object.send(:query_for_status)).to eq('query([{
          exists: {field: "talent_token.contract_id"}
        }, {
          range: {
            "talent_token.deployed_at": {
              gte: 1.month.ago
            }
          }
        }])')
      end
    end

    context "when the status is Pending approval" do
      let(:admin_or_moderator) { true }

      let(:filter_params) do
        {
          status: "Pending approval"
        }
      end

      it "returns the query" do
        expect(search_object.send(:query_for_status)).to eq('query({match: {"user.profile_type": "waiting_for_approval"}})')
      end
    end

    context "when the status is By Polygon Network" do
      let(:filter_params) do
        {
          status: "By Polygon Network"
        }
      end

      it "returns the query" do
        expect(search_object.send(:query_for_status)).to eq("query([{
          exists: {field: 'talent_token.contract_id'}
        }, {
          match: {'talent_token.chain_id': 80001}
        }])")
      end
    end

    context "when the status is By Celo Network" do
      let(:filter_params) do
        {
          status: "By Celo Network"
        }
      end

      it "returns the query" do
        expect(search_object.send(:query_for_status)).to eq("query([{
          exists: {field: 'talent_token.contract_id'}
        }, {
          match: {'talent_token.chain_id': 44787}
        }])")
      end
    end

    context "when the status is not present" do
      let(:filter_params) do
        {
          status: nil
        }
      end

      it "returns the default query" do
        expect(search_object.send(:query_for_status)).to eq("query({match_all: {}})")
      end
    end
  end
end
