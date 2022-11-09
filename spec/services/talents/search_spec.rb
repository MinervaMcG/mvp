require "rails_helper"

RSpec.describe Talents::Search do
  subject(:search_talents) do
    described_class.new(
      filter_params: filter_params,
      sort_params: sort_params,
      discovery_row: discovery_row
    ).call
  end

  let(:sort_params) { {} }
  let(:discovery_row) { nil }

  let!(:user_1) { create :user, talent: talent_1, username: "jonas" }
  let(:talent_1) { create :talent, :with_token, public: true }
  let!(:user_2) { create :user, profile_type: "talent", talent: talent_2, display_name: "Alexander" }
  let(:talent_2) { create :talent, :with_token, public: true }
  let!(:user_3) { create :user, profile_type: "talent", talent: talent_3, username: "jonathan" }
  let(:talent_3) { create :talent, :with_token, public: true }
  let!(:user_4) { create :user, profile_type: "talent", talent: talent_4, display_name: "Alex" }
  let(:talent_4) { create :talent, :with_token, public: true }

  let!(:private_user) { create :user, talent: private_talent, display_name: "Alexandrina", profile_type: "waiting_for_approval" }
  let(:private_talent) { create :talent, :with_token, public: false }

  let!(:user_without_token) { create :user, talent: talent_without_token, username: "jona" }
  let(:talent_without_token) { create :talent, public: true }

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

  context "when filter params are empty" do
    let(:filter_params) { {} }

    it "returns all talent users" do
      expect(search_talents).to match_array([talent_1, talent_2, talent_3, talent_4, talent_5, talent_without_launched_token, verified_talent, celo_talent, polygon_talent])
    end
  end

  context "when the keyword filter is passed" do
    context "when it matches the user username" do
      let(:filter_params) do
        {
          keyword: "jona"
        }
      end

      it "returns all talent users with username matching the passed keyword" do
        expect(search_talents).to match_array([talent_1, talent_3])
      end
    end

    context "when it matches the user display_name" do
      let(:filter_params) do
        {
          keyword: "ale"
        }
      end

      it "returns all talent users with display_name matching the passed keyword" do
        expect(search_talents).to match_array([talent_2, talent_4, talent_without_launched_token])
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
      end

      it "returns all talent users with tags matching the passed keyword" do
        expect(search_talents).to match_array([talent_1, talent_3])
      end
    end
  end

  context "when the discovery row is passed" do
    let(:discovery_row) { create :discovery_row, title: "web3" }

    let(:filter_params) { {} }

    before do
      tag_1 = create :tag, description: "crypto"
      tag_2 = create :tag, description: "blockchain"
      tag_3 = create :tag, description: "developer"

      discovery_row.tags << [tag_1, tag_2, tag_3]

      user_1.tags << [tag_1, tag_3]
      user_2.tags << [tag_2]
      user_3.tags << [tag_1, tag_2]
      private_user.tags << [tag_1]
    end

    it "returns all talent users that are part of the discovery row and have a talent profile type" do
      expect(search_talents).to match_array([talent_2, talent_3])
    end

    context "when the keyword filter is passed" do
      let(:filter_params) do
        {
          keyword: "jona"
        }
      end

      it "returns all talent users part of the discovery row with username matching the passed keyword and have a talent profile type" do
        expect(search_talents).to match_array([talent_3])
      end
    end
  end

  context "when the status filter is passed" do
    context "when the status filter is Trending or Latest added" do
      let(:filter_params) do
        {
          status: "Trending"
        }
      end

      it "returns all latest added or trending talents" do
        expect(search_talents).to match_array([talent_5])
      end
    end

    context "when the status filter is Launching soon" do
      let(:filter_params) do
        {
          status: "Launching soon"
        }
      end

      it "returns all latest talents without tokens" do
        expect(search_talents).to match_array([talent_without_launched_token])
      end
    end

    context "when the status filter is Verified" do
      let(:filter_params) do
        {
          status: "Verified"
        }
      end

      it "returns all latest talents that are verified" do
        expect(search_talents).to match_array([verified_talent])
      end
    end

    context "when the status filter is Pending approval" do
      let(:filter_params) do
        {
          status: "Pending approval"
        }
      end

      it "does not return private talents that are pending approval" do
        expect(search_talents).not_to include(private_talent)
      end
    end

    context "when the status filter is By Celo Network" do
      let(:filter_params) do
        {
          status: "By Celo Network"
        }
      end

      it "returns all latest talents that are launched on Celo network" do
        expect(search_talents).to match_array([celo_talent])
      end
    end

    context "when the status filter is By Polygon Network" do
      let(:filter_params) do
        {
          status: "By Polygon Network"
        }
      end

      it "returns all latest talents that are launched on Polygon network" do
        expect(search_talents).to match_array([polygon_talent])
      end
    end
  end

  context "when the user is an admin or a moderator" do
    context "when the status filter is passed" do
      subject(:search_talents) do
        described_class.new(
          admin_or_moderator: true,
          discovery_row: discovery_row,
          filter_params: filter_params,
          sort_params: sort_params
        ).call
      end

      context "when the status filter is Pending approval" do
        let(:filter_params) do
          {
            status: "Pending approval"
          }
        end

        it "returns talents that are pending approval" do
          expect(search_talents).to include(private_talent)
        end
      end
    end
  end
end
