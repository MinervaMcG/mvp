require "rails_helper"

RSpec.describe DiscoveryRow, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:partnership).optional }
    it { is_expected.to have_many(:tags) }
    it { is_expected.to have_many(:visible_tags) }
  end

  describe "validations" do
    subject { build :discovery_row }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe "#slug" do
    let(:discovery_row) { build :discovery_row, title: "Talent Protocol Team" }

    it "generates a slug based on the title on save" do
      discovery_row.save!

      expect(discovery_row.slug).to eq "talent-protocol-team"
    end
  end

  describe "#talents_count" do
    let!(:user_1) { create :user, talent: talent_1, username: "jonas", profile_completed_at: Time.current }
    let(:talent_1) { create :talent, :with_token, public: true }
    let!(:user_2) { create :user, talent: talent_2, display_name: "Alexander", profile_completed_at: Time.current }
    let(:talent_2) { create :talent, :with_token, public: true }
    let!(:user_3) { create :user, talent: talent_3, username: "jonathan", profile_completed_at: Time.current }
    let(:talent_3) { create :talent, :with_token, public: true }
    let!(:user_4) { create :user, talent: talent_4, display_name: "Alex", profile_completed_at: Time.current }
    let(:talent_4) { create :talent, :with_token, public: true }

    let!(:private_user) { create :user, talent: private_talent, display_name: "Alexandrina", profile_completed_at: Time.current }
    let(:private_talent) { create :talent, :with_token, public: false }

    let(:discovery_row) { create :discovery_row, title: "web3" }

    before do
      tag_1 = create :tag, description: "crypto"
      tag_2 = create :tag, description: "blockchain"
      tag_3 = create :tag, description: "developer"

      discovery_row.tags << [tag_1, tag_2, tag_3]

      user_1.tags << [tag_1, tag_3]
      user_3.tags << [tag_1, tag_2]
      user_4.tags << [tag_1]
      private_user.tags << [tag_1]
    end

    it "returns the number of public talent profiles that belong to the discovery row" do
      expect(discovery_row.talents_count).to eq 3
    end
  end

  describe "#talents_total_supply" do
    let!(:user_1) { create :user, talent: talent_1, username: "jonas", profile_completed_at: Time.current }
    let(:talent_1) { create :talent, :with_token, public: true, total_supply: "100000000000000000000" }
    let!(:user_2) { create :user, talent: talent_2, display_name: "Alexander", profile_completed_at: Time.current }
    let(:talent_2) { create :talent, :with_token, public: true, total_supply: "200000000000000000000" }

    let!(:private_user) { create :user, talent: private_talent, display_name: "Alexandrina" }
    let(:private_talent) { create :talent, :with_token, public: false }

    let(:discovery_row) { create :discovery_row, title: "web3" }

    before do
      tag_1 = create :tag, description: "crypto"
      tag_2 = create :tag, description: "blockchain"
      tag_3 = create :tag, description: "developer"

      discovery_row.tags << [tag_1, tag_2, tag_3]

      user_1.tags << [tag_1, tag_3]
      user_2.tags << [tag_1]
      private_user.tags << [tag_1]
    end

    it "returns the sum of the total supply of public talent profiles that belong to the discovery row" do
      expect(discovery_row.talents_total_supply).to eq "300000000000000000000"
    end
  end

  describe "#with_completed_talents" do
    let!(:discovery_one) { create :discovery_row }
    let!(:partnership_one) { create :partnership, discovery_row: discovery_one }

    let!(:discovery_two) { create :discovery_row }

    let!(:discovery_three) { create :discovery_row }
    let!(:partnership_three) { create :partnership, discovery_row: discovery_three }

    let(:user) { create :user, profile_completed_at: Time.current }
    let!(:talent) { create :talent, user: user, public: true, hide_profile: false }

    let(:tag_one) { create :tag, discovery_row: discovery_one }
    let(:tag_two) { create :tag, discovery_row: discovery_two }

    before do
      create :user_tag, user: user, tag: tag_one
      create :user_tag, user: user, tag: tag_two
    end
    it "returns only discovery rows with talents with a complete profile" do
      expect(described_class.with_completed_talents).to match_array([discovery_one, discovery_two])
    end
  end
end
