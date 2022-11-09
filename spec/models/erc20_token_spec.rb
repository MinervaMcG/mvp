require "rails_helper"

RSpec.describe Erc20Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build :erc20_token }

    it { is_expected.to validate_presence_of(:address) }
  end

  describe ".erc_20?" do
    subject { build :erc20_token }

    it "returns true" do
      expect(subject.erc_20?).to eq true
    end
  end

  describe "#erc_721?" do
    subject { build :erc20_token }

    it "returns false" do
      expect(subject.erc_721?).to eq false
    end
  end
end
