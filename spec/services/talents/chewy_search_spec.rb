require "rails_helper"

RSpec.describe Talents::ChewySearch do
  subject(:search_talents) do
    described_class.new(
      filter_params: filter_params,
      admin_or_moderator: true,
      searching_user: user_1
    ).call
  end

  let!(:user_1) { create :user, talent: talent_1, username: "jonas", profile_type: "waiting_for_approval" }
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

  context "when is filtered by keyword" do
    context "when it matches the user username" do
      let(:filter_params) do
        {
          keyword: "on",
          status: "Admin all"
        }
      end

      it "returns all talent users with username matching the passed keyword" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array(
          [talent_1, talent_3, talent_without_token].pluck(:id)
        )
      end
    end

    context "when it matches the user display_name" do
      let(:filter_params) do
        {
          keyword: "lex",
          status: "Admin all"
        }
      end

      it "returns all talent users with display_name matching the passed keyword" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array(
          [talent_2, talent_4, talent_without_launched_token].pluck(:id)
        )
      end
    end

    context "when it matches the user tags" do
      let(:filter_params) do
        {
          keyword: "web3",
          status: "Admin all"
        }
      end

      it "returns all talent users with tags matching the passed keyword" do
        tag_1 = create :tag, description: "web3"
        tag_2 = create :tag, description: "design"
        tag_3 = create :tag, description: "development"

        user_1.tags << [tag_1, tag_3]
        user_2.tags << [tag_2]
        user_3.tags << [tag_1, tag_2]
        user_4.tags << [tag_3]

        TalentsIndex.import!
        expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_1, talent_3].pluck(:id))
      end
    end
  end

  context "when is filtered by watchlist" do
    let(:filter_params) do
      {
        status: "Admin all",
        watchlist_only: "true"
      }
    end

    before do
      create :follow, user: user_2, follower: user_1
    end

    it "returns user they are following" do
      expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_2].pluck(:id))
    end
  end

  context "when is filtered by status" do
    context "when status is Admin all" do
      let(:filter_params) do
        {
          status: "Admin all"
        }
      end

      it "returns filtered users" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array(Talent.joins(:user).pluck(:id))
      end
    end

    context "when status is Pending approval" do
      let(:filter_params) do
        {
          status: "Pending approval"
        }
      end

      it "returns filtered users" do
        expect(search_talents[1].map { |t| t["id"] }).to match_array([talent_1.id])
      end
    end
  end
end
