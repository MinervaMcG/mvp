require "rails_helper"

RSpec.describe UserDomain, type: :model do
  subject { build :user_domain, user: build(:user), domain: "ruben.dao", chain_id: 137, wallet: SecureRandom.hex }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:domain) }
    it { is_expected.to validate_presence_of(:wallet) }
    it { is_expected.to validate_presence_of(:chain_id) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to([:wallet, :domain, :chain_id]) }
  end
end
